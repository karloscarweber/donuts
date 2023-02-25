require 'phlex'

module Phlex
	
	module ClassMethods
		def methodthing(arg, &block)
			# code execution of the method thing.
		end
	end

	def self.included(mod)
		mod.extend(ClassMethods)
	end

	# required for compliance reasons
	def self.setup(app, *a, &block) end
	
end