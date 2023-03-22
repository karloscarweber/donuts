# Preloader
module Camping end
class Camping::Preloader

	class << self
		def activate(app=nil)

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
			end unless app == nil

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
