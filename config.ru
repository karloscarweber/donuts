# config.ru
require 'irb'
require 'erb'

# I assume we'll use config.ru as a mostly untouched (by users) entry point to their application code.
# So we'll figure this out later i guess.

# require_relative 'basic'

# this is our test stuff:
require_relative 'camping-rewrite' # The camping code.
require_relative 'camp' # MY App Code

# Start the server the way you ought to.
# run Camping::Server

# Runs the server
# run Camping::Server.new
# ARGV.clear
# Uncomment the below if you want to run a console
# IRB.start
# exit
