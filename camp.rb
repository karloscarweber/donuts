# require 'camping'

require_relative 'lib/camping'
# maybe camp.rb is where we configure our app, and give it a name.

require_relative 'lib/gear/phlex'
# require_relative 'lib/middleware/extremeSpeed'

# Camping.goes makes a new Camping App and names it Donuts.
Camping.goes :Donuts
# Then maybe it loads everything in app
# loads lib after the app? The order that stuff is loaded might be weird.

# Extensions to Dir class
# class Dir
# 	class << self
# 	end
# end


# Preloader 
# All this preloading stuff probably shouldn't be here. We can move it later.
class Camping::Preloader
	
	class << self
		def activate()
			
			names = [
				'models',
				'middleware',
				'helpers',
				'views',
				'jobs',
				'controllers',
				'routes'
			]
			
			# grab all first level ('app/') files and folders
				# starting with controller, load the file first, then the index.rb if there is one in a folder, then the other things.
				# iterate through names
				
			names.each do |name|
				puts name
				recursive_load(name)
			end
			
		end
		
		private
		
		DIRS = dirs_in_list = lambda { |list| list.select { |d| Dir.exist?(d) } }
		RUBIES = rubies_in_list = lambda { |list| list.select { |d| !Dir.exist?(d) && (d[-3..-1] == ".rb") } }
		INDEX = index_in_rubies = lambda { |list| list.select { |d| d == "index.rb" } }
		
		# recursively loads 
		def recursive_load(name='',nesting="#{Dir.pwd}/app/", nested=false)
			# puts "loading recursive load"
			# puts "name: '#{name}', nesting: '#{nesting}', nested: '#{nested}'"
			
			# get all items in this directory!
			items = Dir.glob("#{nesting}*")
			directories = DIRS.call(items)
			
			# puts "items:"
			# puts items
			
			# puts "directories:"
			# puts directories
			
			# If we are not nested
			if nested == false
				# We are in the root of the app directory.
				# in the root we load the NAME file, which is a .rb file
				# then pass on to a recursive load.
				rubys = RUBIES.call(items).select {|d| d != "index" }
					
				rubyname = "#{nesting}#{name}.rb"
				namedruby = rubys.select { |r| r == rubyname }
				if namedruby.length > 0
					puts "loading #{namedruby}"
					load "#{namedruby.first}" 
				end
				
				named_directory = directories.select {|d| d.split('/').last == name}
				if named_directory.length > 0
					recursive_load("", "#{named_directory.first}/", true)
				end
			else
				# we are loading recursively. Which means we first load an index.rb file.
				# then we load every .rb file in alphabetical order.
				# then we feed directories into the recursive loader.
				
				index = INDEX.call(items)
				rubys = RUBIES.call(items).select {|d| d != "index" }
				
				if index.length > 0
					puts "loading #{nesting}#{index}"
					load "#{nesting}#{index.first}" 
				end
				
				rubys.each { |r|
					puts "loading #{r}"
					load "#{r}"
				}
				
				# recursively load directories if it's nested.
				directories.each { |d|
					recursive_load(d[0..-2], "#{d}/", true)
				} if nested == true
			
			end		
			
		end
		
		
	end
	
end
Camping::Preloader.activate


# we can add plugins or middleware directly to Donuts now.
Donuts.pack Phlex # plugin
# Donuts.use Camping::Middleware::ExtremeSpeed # middleware

# this is old camping stuff that I think we should keep here so I have a quick reference to some of the silliness there.

#
# module Donuts
#
#   module Models
#
#   end
#
#   module Controllers
#     class Index
#       def get
#         @title = "donuts"
#         render :index
#       end
#     end
#
#   end
#
#   module Helpers
#   end
#
#   module Views
#
#     def layout
#       html do
#         head do
#           title 'donuts'
#           link :rel => 'stylesheet', :type => 'text/css',
#           :href => '/styles.css', :media => 'screen'
#         end
#         body do
#           h1 'donuts'
#
#           div.wrapper! do
#             self << yield
#           end
#         end
#       end
#     end
#
#     def index
#       h2 "Let's go Camping"
#     end
#
#   end
#
# end

