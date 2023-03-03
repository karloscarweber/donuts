# require 'camping'

# require_relative 'lib/camping'
# maybe camp.rb is where we configure our app, and give it a name.

# require_relative 'lib/gear/phlex'
# require_relative 'lib/middleware/extremeSpeed'

# Camping.goes makes a new Camping App and names it Donuts.
# Camping.goes :Donuts
# Then maybe it loads everything in app
# loads lib after the app? The order that stuff is loaded might be weird.


# Camping::Preloader.activate

# We can add plugins or middleware directly to Donuts now.
# Donuts.pack Phlex # plugin
# Donuts.use Camping::Middleware::ExtremeSpeed # middleware



# puts "#{Camping::Apps}"

# I thought we would need to call this to setup routes.
# Camping::Apps.each { |app|
# 	app.M
# }

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