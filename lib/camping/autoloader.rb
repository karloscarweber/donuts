# lib/camping/autoloader.rb
require 'zeitwerk'

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
				@directory ||= Dir.pwd
				# namespaced_name, hop = app.name.gsub(/::/, '/').downcase, "#{@directory}/apps"
				hop =  "#{@directory}/apps"
				# Loader.push_dir("#{hop}", namespace: namespace)
				Loader.push_dir("#{hop}")
			end

			def setup
				Loader.setup
			end

		end
	end
end
