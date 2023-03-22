# Camping Server stuff first
module Camping

	# delete this module later. Just here to satisfy autoloading
	module ServerNew end

	# The Server object, that's just Rackup Server
	class Server < Rackup::Server

		class << self
			# Receives a list of apps from the Camping Object
			# Then enumerates over and finds every folder and file associated with that App.
			# Then loads every file in a predictable order.
			def setup_loaders

				# add Autoloading for Camping namespaced stuff. Basically things in the root of apps/
				Camping::Autoloader::Loader.push_dir("#{Dir.pwd}/lib")

				# Now add autoloading for subfolders in the apps directory, like apps/donuts/
				Camping::Apps.each do |app|
					Camping::Autoloader.with_app(app) unless app._meta.parent != nil
				end
				Camping::Autoloader.setup
			end
		end

		class Options

      def parse!(args)
        args = args.dup
        options = {}
        opt_parser = OptionParser.new("", 24, '  ') do |opts|
          opts.banner = "Usage: camping Or: camping my-camping-app.rb"

          opts.define_head "#{File.basename($0)}, the microframework ON-button for ruby #{RUBY_VERSION} (#{RUBY_RELEASE_DATE}) [#{RUBY_PLATFORM}]"

          opts.separator ""
          opts.separator "Specific options:"

          opts.on("-h", "--host HOSTNAME",
          "Host for web server to bind to (default is all IPs)") { |v| options[:Host] = v }

          opts.on("-p", "--port NUM",
          "Port for web server (defaults to 3301)") { |v| options[:Port] = v }

          opts.on("-c", "--console",
          "Run in console mode with IRB") { options[:server] = "console" }

          opts.on("-e", "--env ENVIRONMENT",
          "Sets the environment. (defaults: development)") { |v| options[:environment] = ENV['environment'] = v }

          server_list = ["thin", "webrick", "console", "puma", "tipi", "falcon"]
          opts.on("-s", "--server NAME",
          "Server to force (#{server_list.join(', ')})") { |v| options[:server] = v }

          opts.separator ""
          opts.separator "Common options:"

          # No argument, shows at tail.  This will print an options summary.
          # Try it and see!
          opts.on("-?", "--help", "Show this message") do
            puts opts
            exit
          end

          # Another typical switch to print the version.
          opts.on("-v", "--version", "Show version") { options[:version] = true }

          # Show Routes
          opts.on("-r", "--routes", "Show Routes") { options[:routes] = true }

        end

        opt_parser.parse!(args)

        if args.empty?
          args << "camp.rb"
        end

        options[:script] = args.shift
        options
      end
    end

    def initialize(*)
      super
      # figure out a new reloader method.
      # @reloader = Camping::Reloader.new(options[:script]) do |app|
      #   if !app.options.has_key?(:dynamic_templates)
		    #   app.options[:dynamic_templates] = true
	     #  end
      # end
    end

    def opt_parser
      Options.new
    end

    def default_options
      super.merge({
        :Port => 3301
      })
    end

    def middleware
      h = super
      h["development"] << [XSendfile]
      h
    end

    def start
			commands = []
      ARGV.each do |cmd|
        commands << cmd
      end

      # Parse commands
      # case commands[0]
      # when "new"
      #   Camping::Commands.new_cmd(commands[1])
      #   exit
      # end

      if options[:version] == true
        puts "Camping v#{Camping::VERSION}"
        exit
      end

			# setup loaders
			Camping::Server.setup_loaders
			if options[:server] == "console"
        puts "🏕  Starting console"
        # @reloader.reload!
        # r = @reloader
        eval("self", TOPLEVEL_BINDING).meta_def(:reload!) { r.reload!; nil }
        ARGV.clear
        IRB.start
        exit
      # else if options[:server] == "falcon"
      #   name = server.name[/\w+$/]
      #   puts "** Starting #{name} on #{options[:Host]}:#{options[:Port]}"
      #   # puts `falcon serve --port 3000`
      #   super
      else
        name = server.name[/\w+$/]
        puts "🏕  Starting #{name} on #{options[:Host]}:#{options[:Port]}"
        super
      end
		end

	  # defines the public directory to be /public
    def public_dir
      File.expand_path('../public', __FILE__)
    end

    # add the public directory as a Rack app serving files first, then the
    # current value of self, which is our camping apps, as an app.
    def app
      Rack::Cascade.new([Rack::Files.new(public_dir), self], [405, 404, 403])
    end

    # path_matches?
    # accepts a regular expression string
    # in our case our apps and controllers
    def path_matches?(path, *reg)
      p = T.(path)
      reg.each do |r|
        return true if Regexp.new(T.(r)).match?(p) && p == T.(r)
      end
      false
    end

    # Ensure trailing slash lambda
    T ||= -> (u) {
      if u.last != "/"
        u << "/"
      end
      return u
    }

    # All the magic happens here.
		def call(env)

			@apps ||= Camping::Apps
			Camping.routes

			# [200, {}, ["Hello World"]]
			# Here put a matcher thing that cycles through our Apps and their routes.

			case @apps.length
      when 0
        [200, {'content-type' => 'text/html'}, ["I'm sorry but no apps were found."]]
      when 1
        @apps.first.call(env) # When we have one
      else
        # 2 and up get special treatment
        @apps.each do |name, app|
          app.routes.each do |r|
            if (path_matches?(env['PATH_INFO'], r))
              return app.call(env)
              next
            end
          end
        end

        # Just return the first app if we didn't find a match.
        return @apps.first.call(env)
      end

		end

    class XSendfile
      def initialize(app)
        @app = app
      end

      def call(env)
        status, headers, body = @app.call(env)

        if key = headers.keys.grep(/X-Sendfile/i).first
          filename = headers[key]
          content = open(filename,'rb') { | io | io.read}
          headers['Content-Length'] = size(content).to_s
          body = [content]
        end

        return status, headers, body
      end

      if "".respond_to?(:bytesize)
        def size(str)
          str.bytesize
        end
      else
        def size(str)
          str.size
        end
      end
    end

	end
end
