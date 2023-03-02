# app/controllers/profile/index.rb

# these routes are defined under '/profile/'
# maybe this file is loaded via module_eval into Camping::Controllers?

module Donuts::Controllers
	class Profile < Camper
		_layout -> { :app_layout }

		def get()
			"Return a profile" # returning raw strings is supported
		end
	end
	
	# Ok the idea here is that Edit, will be at the '/profile/edit' route because it inherits from Profile.
	class Edit < Profile
		# layout is inherited from Profile, along with before and middleware
		def get
			"Return an Edit thing."
		end
	end
end