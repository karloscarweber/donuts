module Camping

# Camping::Base is built into each controller by way of the generic routing
  # class Camping::R. In some ways, this class is trying to do too much, but
  # it saves code for all the glue to stay in one place. Forgivable,
  # considering that it's only really a handful of methods and accessors.
  #
  # Everything in this module is accessible inside your controllers.
  module Base
    attr_accessor :env, :request, :root, :input, :cookies, :state,
                  :status, :headers, :body, :url_prefix

    T = {}
    L = :layout

    # Finds a template, returning either:
    #
    #   false             # => Could not find template
    #   true              # => Found template in Views
    #   instance of Tilt  # => Found template in a file
    def lookup(n)
      T.fetch(n.to_sym) do |k|
        # Find a view defined in the Views module first
        t = Views.method_defined?(k) ||
          (t = O[:_t].keys.grep(/^#{n}\./)[0]and Template[t].new{O[:_t][t]}) ||
          (f = Dir[[O[:views] || "views", "#{n}.*"]*'/'][0]) &&
          Template.new(f, O[f[/\.(\w+)$/, 1].to_sym] || {})
        O[:dynamic_templates] ? t : T[k] = t
      end
    end

    # Display a view, calling it by its method name +v+. If a <tt>layout</tt>
    # method is found in Camping::Views, it will be used to wrap the HTML.
    #
    #   module Nuts::Controllers
    #     class Show
    #       def get
    #         @posts = Post.find :all
    #         render :index
    #       end
    #     end
    #   end
    #
    def render(v, *a, &b)
      if t = lookup(v)
        r = @_r
        @_r = (o = Hash === a[-1] ? a.pop : {})
        s = (t == true) ? mab { send(v, *a, &b) } : t.render(self, o[:locals] || {}, &b)
        s = render(L, o.merge(L => false)) { s } if o[L] or o[L].nil? && lookup(L) && !r && v.to_s[0] != ?_
        s
      else
        raise "no template: #{v}"
      end
    end

    # You can directly return HTML from your controller for quick debugging
    # by calling this method and passing some Markaby to it.
    #
    #   module Nuts::Controllers
    #     class Info
    #       def get; mab{ code @headers.inspect } end
    #     end
    #   end
    #
    # You can also pass true to use the :layout HTML wrapping method
    def mab(&b)
      extend Mab
      mab(&b)
    end

    # A quick means of setting this controller's status, body and headers
    # based on a Rack response:
    #
    #   r(302, 'Location' => self / "/view/12", '')
    #   r(*another_app.call(@env))
    #
    # You can also switch the body and the header if you want:
    #
    #   r(404, "Could not find page")
    #
    # See also: #r404, #r500 and #r501
    def r(s, b, h = {})
      b, h = h, b if Hash === b
      @status = s
      @headers.merge!(h)
      @body = b
    end

    # Formulate a redirect response: a 302 status with <tt>Location</tt> header
    # and a blank body. Uses Helpers#URL to build the location from a
    # controller route or path.
    #
    # So, given a root of <tt>http://localhost:3301/articles</tt>:
    #
    #   redirect "view/12"  # redirects to "//localhost:3301/articles/view/12"
    #   redirect View, 12   # redirects to "//localhost:3301/articles/view/12"
    #
    # <b>NOTE:</b> This method doesn't magically exit your methods and redirect.
    # You'll need to <tt>return redirect(...)</tt> if this isn't the last statement
    # in your code, or <tt>throw :halt</tt> if it's in a helper.
    #
    # See: Controllers
    def redirect(*a)
      r(302,'','Location'=>URL(*a).to_s)
    end

    # Called when a controller was not found. You can override this if you
    # want to customize the error page:
    #
    #   module Nuts
    #     def r404(path)
    #       @path = path
    #       render :not_found
    #     end
    #   end
    def r404(p)
      P % "#{p} not found"
    end

    # Called when an exception is raised. However, if there is a parse error
    # in Camping or in your application's source code, it will not be caught.
    #
    # +k+ is the controller class, +m+ is the request method (GET, POST, etc.)
    # and +e+ is the Exception which can be mined for useful info.
    #
    # By default this simply re-raises the error so a Rack middleware can
    # handle it, but you are free to override it here:
    #
    #   module Nuts
    #     def r500(klass, method, exception)
    #       send_email_alert(klass, method, exception)
    #       render :server_error
    #     end
    #   end
    def r500(k,m,e)
      raise e
    end

    # Called if an undefined method is called on a controller, along with the
    # request method +m+ (GET, POST, etc.)
    def r501(m)
      P % "#{m.upcase} not implemented"
    end

    # Serves the string +c+ with the MIME type of the filename +p+.
    # Defaults to text/html.
    def serve(p, c)
      t = Rack::Mime.mime_type(p[/\..*$/], Z) and @headers[E] = t
      c
    end

    # Turn a controller into a Rack response. This is designed to be used to
    # pipe controllers into the <tt>r</tt> method. A great way to forward your
    # requests!
    #
    #   class Read < '/(\d+)'
    #     def get(id)
    #       Post.find(id)
    #     rescue
    #       r *Blog.get(:NotFound, @headers.REQUEST_URI)
    #     end
    #   end
    def to_a
      @env['rack.session'][SK] = Hash[@state]
      r = Rack::Response.new(@body, @status, @headers)
      @cookies._n.each do |k, v|
        r.set_cookie(k, v)
      end
      r.to_a
    end

    def initialize(env, m, p) #:nodoc:
      r = @request = Rack::Request.new(@env = env)
      @root, @input, @cookies, @state,
      @headers, @status, @method, @url_prefix =
      r.script_name.sub(/\/$/,''), n(r.params),
      Cookies[r.cookies], H[r.session[SK]||{}],
      {E=>Z}, m =~ /r(\d+)/ ? $1.to_i : 200, m, p
      @cookies._p = self/"/"
    end

    def n(h) # :nodoc:
      if Hash === h
        h.inject(H[]) do |m, (k, v)|
          m[k] = n(v)
          m
        end
      else
        h
      end
    end

    # All requests pass through this method before going to the controller.
    # Some magic in Camping can be performed by overriding this method.
    def service(*a)
      r = catch(:halt){
      	_before if @_before != nil
	      send(@method, *a)

      }
      @body ||= r
      self
    end

    # add the block based method stuff.
		def self.included(mod)
			mod.extend(ClassMethods)
		end
		module ClassMethods
			@_before = -> {}
			def _before(&block)
				@_before = block
			end

			def _before
				@_before.call() if @_before != nil
			end

		end

  end
end






# Core stuff for apps and shit.

module Camping
	C = self
  S = IO.read(__FILE__) rescue nil
  P = "<h1>Cam\ping Problem!</h1><h2>%s</h2>"
  U = Rack::Utils
  # O = { url_prefix: "" } # Our Hash of Options. Moved below H
  Apps = [] # Our array of Apps
  SK = :camping #Key for r.session
  G = [] # Our array of Gear



	# the core functionality of Camping.
	module Core
	  module ClassMethods
	  	# Define Class Methods here
	  end
	  def self.included(mod)
	  mod.extend(ClassMethods)
	  end
	end
end

module Camping
	include CampingBase
end
