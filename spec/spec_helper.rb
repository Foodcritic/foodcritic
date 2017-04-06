require "shellwords"

require "rspec_command"
require "simplecov"

SimpleCov.start do
  add_filter "/spec/"
end

module FunctionalHelpers
  extend RSpec::Matchers::DSL

  matcher :violate_rule do |rule_id|
    match do |cmd|
      if location
        cmd.stdout =~ /^#{rule_id}:.*: \.\/#{location}/
      else
         cmd.stdout =~/^#{rule_id}:/
      end
    end
    chain :in, :location
    failure_message do |cmd|
      "expected a violation of rule #{rule_id}#{location && " in #{location}"}, output was:\n#{cmd.stdout}"
    end
  end

  module ClassMethods
    def foodcritic_command(*args)
      # TODO this could work in-process in the future.
      bin_path = File.expand_path("../../bin/foodcritic", __FILE__)
      command("#{bin_path} #{Shellwords.join(args)}", allow_error: true)
    end

    def attributes_file(*args, &block)
      file("attributes/default.rb", *args, &block)
    end

    def recipe_file(*args, &block)
      file("recipes/default.rb", *args, &block)
    end

    def included(klass)
      super
      klass.extend ClassMethods
      # Set a default subject command, can be overridden if needed.
      klass.foodcritic_command(".")
    end
  end

  extend ClassMethods
end

RSpec.configure do |config|
  config.define_derived_metadata(file_path: %r{spec/functional}) do |metadata|
    metadata[:functional] = true
  end

  config.include RSpecCommand
  config.include FunctionalHelpers, functional: true
end

require_relative "../lib/foodcritic"
