# config.ru

require 'camping'
require 'camping/server'

# I assume we'll use config.ru as a mostly untouched (by users) entry point to their application code.
# So 

require_relative 'camp'

run Camping::Server

