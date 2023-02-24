require 'camping'

# I'll probably rethink all of this syntax '
Camping.goes :Donuts
Donuts.pack FrankStyle

module Donuts

    get '/' do
        "welcome to the whatever"
    end

    get '/home' do
        "whatever"
    end

end


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

