# config.ru
require 'irb'
require 'erb'

# I assume we'll use config.ru as a mostly untouched (by users) entry point to their application code.
# So we'll figure this out later i guess.

# require_relative 'basic'

# Runs the server
run Glamp::Server
ARGV.clear
IRB.start
exit