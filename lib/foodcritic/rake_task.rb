require 'rake'
require 'rake/tasklib'
require 'foodcritic'

module FoodCritic
  module Rake
    class LintTask < ::Rake::TaskLib
      attr_accessor :name, :files
      attr_writer :options

      def initialize(name = :foodcritic)
        @name = name
        @files = [Dir.pwd]
        @options = {}
        yield self if block_given?
        define
      end

      def options
        {:fail_tags => ['correctness'], # differs to default cmd-line behaviour
         :cookbook_paths => @files,
         :exclude_paths => ['test/**/*', 'spec/**/*', 'features/**/*']
        }.merge(@options)
      end

      def define
        desc "Lint Chef cookbooks"
        task(name) do
          result = FoodCritic::Linter.new.check(options)
          if result.warnings.any?
            puts result
          end

          fail result.to_s if result.failed?
        end
      end

    end
  end
end
