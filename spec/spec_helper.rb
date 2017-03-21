begin
  require "simplecov"
  SimpleCov.start do
    add_filter "/spec/"
  end
rescue LoadError
  warn "warning: simplecov gem not found; skipping coverage"
end

require "minitest/spec"
require "minitest/autorun"
require "minitest/reporters"
MiniTest::Reporters.use!

require_relative "../lib/foodcritic"
