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

module Camping
	module Autoloader
		
		Loader ||= Zeitwerk::Loader.new
		
		Defined = -> (name, parent) { 
			if parent != false
				Object.const_defined?(name.to_s)
			else
				return false unless Object.const_defined?(parent)
				Object.const_defined?(name.to_s)
			end
		}
		
		class << self
		
			def with_app(app, namespace=Object)
				@@directory ||= Dir.pwd
				namespaced_name, hop = app.name.gsub(/::/, '/').downcase, 
				"#{@@directory}/apps"
				Loader.push_dir("#{hop}", namespace: namespace)
			end
			
			def setup
				Loader.setup
			end
			
		end
	end
end
