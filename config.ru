# config.ru

# require 'camping'
# require 'camping/server'

# I assume we'll use config.ru as a mostly untouched (by users) entry point to their application code.
# So we'll figure this out later i guess.

require_relative 'camp'

require_relative 'lib/camping/server'

# start our app in a Rack Compatible way.
run Camping::Server.start
