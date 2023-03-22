# require 'camping'

Camping.goes :Donuts
Camping.goes :Nuts
Camping.goes :Wild
Wild.goes :Wilder # doesn't work right!'
# could also:
# module Wild
# 	goes :Wilder
# end"

module Wild
	module Controllers
    class Home < R 'home'
      def get()
        puts "things"
      end
    end
	end
end
