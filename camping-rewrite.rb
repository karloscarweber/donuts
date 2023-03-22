# Camping Rewrite
# An attempt to rebuild Camping as a really simple Rack App, while then adding all the badass Magic stuff to it.

# old school patching of Object, Consider dropping this in Camping Tools
class Object #:nodoc:
  def meta_def(m,&b) #:nodoc:
    (class<<self;self end).send(:define_method,m,&b)
  end
end

require 'irb'
require 'erb'
require 'rack'
require 'rackup'
require 'rubygems' # gets rubygems
require 'bundler/setup' # grabs stuff from your GemFile.
# require 'rackup' # requires re
require_relative 'lib/camping/autoloader'
require_relative 'lib/camping/preloader'
require_relative 'lib/camping/camping_tools'
require_relative 'lib/camping/server_new'

# include rewrites of camping classics!
require_relative 'lib/camping/base'

module Camping

	VERSION = "3.0"

	# add quick access for Camping Tools
	def self.🏕; CampingTools end

	Apps = []

	# Camping App now will have a module we can inherit from.
	module App

		# controllers and Routes
		module Controllers

			# Route
			# A struct representing a routing in Camping.
			# name: {String} The name of the route. Matches it's class Name
			# url: {String} The url that it matches.
			# pattern: {String} The url pattern that it matches.
			# proc: {Proc} A reference to the procedure that it is executed when this
			#   route is matched.
			Route = Struct.new(:name,:url,:pattern,:proc)
			@r = [] # array of urls

			# The new base controller class for camper.
			class Camper
				include Camping::Base
			end

	    class << self

	      # Add routes to a controller class by piling them into the R method.
	      #
	      # The route is a regexp which will match the request path. Anything
	      # enclosed in parenthesis will be sent to the method as arguments.
	      #
	      #   module Camping::Controllers
	      #     class Edit < R '/edit/(\d+)', '/new'
	      #       def get(id)
	      #         if id   # edit
	      #         else    # new
	      #         end
	      #       end
	      #     end
	      #   end
	      def R *u
	        r=@r
					if u.first.kind_of Camper
						klass = u.shift
					else
						klass = Camper
					end
					klass.new {
						meta_def(:urls){u}
						meta_def(:inherited){|x|r<< x}
					}
					klass
	      end
      end

		end

		# Metadata
		# A struct containing an app's metadata.
		# @name: {String} The app name.
		# @parent: {Object} The app's parent app, Defaults to Camping.
		# @root: {String} The app's root url. it's URL Prefix, basically.
		# @location: {Location}, A struct containing a file name, and line number.
		Metadata = Struct.new(:name,:parent,:root,:location)

		# Location
		# A struct containing an app's definition location
		# @file: {String} The string location and name of the file
		# @line_number: {String} The line number in that file where the app was made.
		Location = Struct.new(:file,:line_number)

		def _meta
			@_meta || nil
		end

		# 	accepts a hash:
		#		:file = String
		#		:line_number = Int
		#   :parent = Object
		def _meta=(new_meta)
			begin
				loc = Location.new(new_meta[:file], new_meta[:line_number])
			  root = (new_meta[:parent] ? '/' + Camping::🏕.to_snake(new_meta[:parent].name.dup) : '/' )
				@_meta = Metadata.new(self.name.to_s, new_meta[:parent], root, loc)
			end unless @_meta != nil
			@_meta
		end

		# Camping::App#goes is a wrapper for Camping#goes that passes
		# self along with the other parameters. This makes the new app
		# an explicit child of the calling app. We use this to build routes, chain
		# filters, and to inherit settings, views, helpers, etc...
		def goes(m, g=TOPLEVEL_BINDING)
			Camping.goes(m, g, self, caller)
		end
	end

	# module methods:
	class << self

		# Add the classic Camping Goes! Gotta keep the magic alive.
		# So Camping Goes Creates a new Camping app instance. Optionally you
		# can pass a binding to bind the new app into a namespace.
		# the goes class method is also executable on Each camping app made so that you
		# can make a new camping app in that new context with a parent, in a super duper
		# easy way.
	 def goes(m, g=TOPLEVEL_BINDING, parent=nil, klr=nil)
			pg = (parent.name.dup.to_s) << "::" if parent != nil
			klr = caller unless klr
			spl = klr[0].split('`').first.split(":")
			file, ln = spl[0], spl[1].to_i

      Apps << a = eval("module #{pg}#{m.to_s}; extend Camping::App;end", g, file, ln)
      # a.module_eval("module Controllers;include Camping::App::ControllersCore;end;")
     	a._meta = {file: file, line_number: ln, parent: parent}
		end
	end

end
