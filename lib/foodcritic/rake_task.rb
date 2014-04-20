require 'rake'
require 'rake/tasklib'

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
        {
          fail_tags: ['correctness'], # differs to default cmd-line behaviour
          cookbook_paths: @files,
          exclude_paths: ['test/**/*', 'spec/**/*', 'features/**/*'],
          context: false,
        }.merge(@options)
      end

      def define
        desc 'Lint Chef cookbooks' unless ::Rake.application.last_comment
        task(name) do
          result = FoodCritic::Linter.new.check(options)
          printer = options[:context] ? ContextOutput.new : SummaryOutput.new
          printer.output(result) if result.warnings.any?
          abort if result.failed?
        end
      end
    end
  end
end
