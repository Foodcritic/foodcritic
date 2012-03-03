require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
end

require 'minitest/autorun'
require 'minitest/pride'
require 'minitest/spec'

require_relative '../lib/foodcritic'
