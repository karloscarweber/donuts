# basic.rb
# An attempt to rebuild Camping as a really simple Rack App, while then adding all tha badass Magic stuff to it.
require 'rackup'

module Glamp
	
	Apps = []
	
	# The Server object, that's just Rackup Server
	class Server < Rackup::Server
		
		# All the magic happens here.
		def call(env)
			
			puts Glamp::Apps
			
			[200, {}, ["Hello World"]]
		end
	end
	
	# Camping App now will have a module we can inherit from.
	module App
		def goes(m, g=TOPLEVEL_BINDING)
			Glamp.goes(m, g, self)
		end
		def _set_parent(parent)
			@@_parent = parent
		end
		def parent
			@@_parent
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
	 def goes(m, g=TOPLEVEL_BINDING, parent=nil)
			pg = (parent.name.dup.to_s) << "::" if parent != nil
			f = caller[0].split("/").last.split(":")[0]
    	Apps << a = eval("module #{pg}#{m.to_s}; extend Glamp::App; end", g, f[0], f[1].to_i)
     	a._set_parent(parent) if parent != nil
    end
	end
	
end

Glamp.goes :Donuts
Glamp.goes :Nuts
Glamp.goes :Wild

# Wild.goes :Wilder, Wild.get_binding
# Wild::Wilder.goes :Wildest, Wild::Wilder.get_binding

Wild.goes :Wilder

puts "parent of Wilder: #{Wild::Wilder.parent} "


# Glamp::Server.start