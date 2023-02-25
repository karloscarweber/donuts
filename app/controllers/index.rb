# index.rb

# assume that routes defined here will be under main route '/'
# maybe this file is loaded via module_eval into Camping::Controllers?

module Donuts::Controllers
	# in this case, < R '/', is rendundant, Camping will convert Index into that.
	class Index < R '/'
		layout -> { AppLayout }

		def get()
			"return a great thing." # returning raw strings is supported
		end
	end
end