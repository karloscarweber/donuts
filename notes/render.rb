# How does rendering work?

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
def render (view, *splats, &block)
	
	if template = lookup(view)
			
		# @_r is like... options or context variables passed along
		r = @_r # Has this controller rendered before?
		
		# Set @_r to a hash value, but also set options value. (options)
		# so splats[-1] grabs the last possible splat. If it's of type Hash
		# then we can safely assume that it's a bunch of values, so we pop it.
		# the popped value is passed to options. otherwise we pass an empty hash.
		# then we assign the result of this process to a variable.
		@_r = (options = Hash === splats[-1] ? splats.pop : {})
		
		s = (template == true) ? mab { send(view, *splats, &block) } : template.render(self, options[:locals] || {}, &block)
	
	else
		raise "no template: #{view}"
	end
end

# Finds a template, returning either:
#
#   false             # => Could not find template
#   true              # => Found template in Views
#   instance of Tilt  # => Found template in a file
def lookup(n)
  T.fetch(n.to_sym) do |k|
    # Find a view defined in the Views module first
    t = Views.method_defined?(k) ||
      # Find inline templates (delimited by @@), and then put it in a new Template and return that.
      # `:_t` is the options key for inline templates. Inline templats are added in `Camping#goes`.
      (t = O[:_t].keys.grep(/^#{n}\./)[0]and Template[t].new{O[:_t][t]}) ||

      # Find templates in a views directory, and return the first view that matches the symbol provided.
      # Then pipe that template file into Template, which is just Tilt.
      (f = Dir[[O[:views] || "views", "#{n}.*"]*'/'][0]) &&

      # Grab any settings set for the template files, as set by their filename extension
      # and add that to the options of Template (Tilt), or an empty Hash
      # What does adding settings for a template look like? :
      #   module Nuts
      #     def r404(path)
      #       @path = path
      #       render :not_found
      #     end
      #   end
      Template.new(f, O[f[/\.(\w+)$/, 1].to_sym] || {})

    O[:dynamic_templates] ? t : T[k] = t
  end
end

# Streaming Header stuff
# 1. Send Headers first
# 2. Send Body Second.