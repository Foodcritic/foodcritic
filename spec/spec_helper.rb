begin
  require "simplecov"
  SimpleCov.start do
    add_filter "/spec/"
  end
rescue LoadError
  warn "warning: simplecov gem not found; skipping coverage"
end

require "minitest/pride"
require "minitest/spec"

require_relative "../lib/foodcritic"
