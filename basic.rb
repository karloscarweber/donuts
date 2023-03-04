# basic.rb
# An attempt to rebuild Camping as a really simple Rack App, while then adding all tha badass Magic stuff to it.
require 'rackup'
require_relative 'lib/extensions/snake'

module Glamp
	
	Apps = []
	
	# The Server object, that's just Rackup Server
	class Server < Rackup::Server
		
		# All the magic happens here.
		def call(env)
			puts Glamp::Apps
			
			[200, {}, ["Hello World"]]
			
			# Here put a matcher thing that cycles through our Apps and their routes.
		end
		
		def start
			puts "start called"
			super
		end
		
	end
	
	# Camping App now will have a module we can inherit from.
	module App
		# Hash that says where the app was loaded from
		@_loaded = {}
		@_root = '/'
		def goes(m, g=TOPLEVEL_BINDING)
			Glamp.goes(m, g, self)
		end
		def _set_parent(parent)
			@_parent = parent
		end
		def parent
			@_parent
		end
		def _loaded_from(a)
			@_loaded = a
			@_root = a[:root]
		end
		def root
			@_root
		end
	end
	
	# module methods:
	class << self
	
		def apps
			Glamp::Apps
		end
	
		# Add the classic Camping Goes! Gotta keep the magic alive.
		# So Camping Goes Creates a new Camping app instance. Optionally you
		# can pass a binding to bind the new app into a namespace.
		# the goes class method is also executable on Each camping app made so that you 
		# can make a new camping app in that new context with a parent, in a super duper
		# easy way.
	 def goes(m, g=TOPLEVEL_BINDING, parent=nil)
			pg = (parent.name.dup.to_s) << "::" if parent != nil
			f = caller[0].split("/").last.split(":")[0]
			file, line_number = f[0], f[1]
    	Apps << a = eval("module #{pg}#{m.to_s}; extend Glamp::App; end", g, file, line_number.to_i)
     	a._set_parent(parent) if parent != nil
      
      # extremely naive way to get the parent and root. 
      # like it sucks gotta improve that.
      root = '/'+parent.name.dup.to_snake if parent != nil
      a._loaded_from( {file: file, line_number:line_number, root: root || '/'})
    end
	end
	
end

Glamp.goes :Donuts
Glamp.goes :Nuts
Glamp.goes :Wild
Wild.goes :Wilder
# could also: 
# module Wild
# 	goes :Wilder
# end"

# What we should be using to start the server.
# starts and initializes the server.
Glamp::Server.start