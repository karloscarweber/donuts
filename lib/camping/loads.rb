# loads.rb
# just loads things into camping.rb

# external dependencies
require "uri"
require 'irb'
require 'erb'
require 'rack'
require 'rackup'
require 'rubygems' # gets rubygems
require 'bundler/setup' # grabs stuff from your

# internal stuff
require 'camping/tools'
require "camping/gear"
require "camping/config"
require "camping/template"
require "camping/session"
require "camping/autoloader"
require "camping/preloader"
require_relative 'lib/camping/server_new'
