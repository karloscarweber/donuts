# lib/camping/autoloader.rb
require 'zeitwerk'

# loader = Zeitwerk::Loader.new

# Controllers
# Views
# Models

# hop = "#{__dir__}/../../app"

# loader.push_dir("#{hop}/", namespace: Donuts)

# loader.push_dir("#{hop}/controllers", namespace: Donuts::Controllers)
# loader.push_dir("#{hop}/views", namespace: Donuts::Views)
# loader.push_dir("#{hop}/models", namespace: Donuts::Models)
# loader.setup

puts "Autoloader setting up."

module Camping
	module Autoloader
		class << self
			def with_app(appname="Camp")
				hop = "#{__dir__}/app"
				# puts Zeitwerk::Registry.loaders
				
				begin
					loader = Zeitwerk::Loader.new
					loader.push_dir("#{hop}/", namespace: appname.to_s)
					loader.setup
					loader.eager_load
					
				end unless Object.const_defined?(appname.to_sym)
			end
		end
	end
end
