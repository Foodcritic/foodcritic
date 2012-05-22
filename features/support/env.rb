require 'simplecov'
SimpleCov.start do
  add_filter '/features/'
end

require 'aruba/cucumber'
require 'pry'
require_relative '../../lib/foodcritic'

Before do
  @aruba_timeout_seconds = 300
end