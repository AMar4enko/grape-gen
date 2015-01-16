# Defines our constants
RACK_ENV = :production
APP_ROOT = File.expand_path('../..', __FILE__) unless defined?(APP_ROOT)

# Load our dependencies
require 'rubygems' unless defined?(Gem)
require 'bundler/setup'
# Load initializers
Bundler.require(:faye, RACK_ENV)
require 'warden'
require 'active_support/core_ext/hash/keys'
require 'hashie/mash'
require 'redis-namespace'
require_relative 'initializers/patches/redis_namespace'
require_relative 'settings'

ApplicationSettings.source File.expand_path('config/application.yml', APP_ROOT)
ApplicationSettings.root = APP_ROOT

require_relative 'initializers/logging'
require_relative '../lib/faye_auth_extension'
require_relative '../lib/faye_publisher'