# app/controllers/home.rb

# assume that routes defined here will be under a home route: '/home'
# maybe this file is loaded via module_eval into Camping::Controllers?

module Donuts::Controllers
	class Home < R '/home/'
		layout -> { AppLayout } # Maybe this is implied
		
		# set before actions with a simple instance_method call.
		before do_something, something_else, more_stuff
		
		# add middleware just to this route.
		middle Camping::Middleware::PerfLogger, 
		
		# define response to the routes here.		
		def get
			render :home, "Welcome Home" # Home view is implied
		end
	end
end
