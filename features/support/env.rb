require 'simplecov'
SimpleCov.start do
  add_filter '/features/'
end

require 'aruba/cucumber'
require 'foodcritic'

require 'minitest/autorun'
require 'minitest/spec'

MiniTest::Spec.new(nil)

Before do
  @aruba_timeout_seconds = 300
end
