require 'rake'
require 'rake/tasklib'

module FoodCritic
  module Rake
    class LintTask < ::Rake::TaskLib
      attr_accessor :name, :files, :options

      def initialize(name = :foodcritic)
        @name = name
        @files = [Dir.pwd]
        @options = {}
        yield self if block_given?
        define
      end


      def define
        desc 'Lint Chef cookbooks' unless ::Rake.application.last_comment
        task(name) do
          puts "Starting Foodcritic linting..."
          result = FoodCritic::Linter.new.check(default_options.merge(options))
          printer = options[:context] ? ContextOutput.new : SummaryOutput.new
          printer.output(result) if result.warnings.any?
          abort if result.failed?
          puts "Completed!"
        end
      end

      private
      def default_options
        {
          fail_tags: ['correctness'], # differs to default cmd-line behaviour
          cookbook_paths: files,
          exclude_paths: ['test/**/*', 'spec/**/*', 'features/**/*'],
          context: false,
          chef_version: FoodCritic::Linter::DEFAULT_CHEF_VERSION
        }
      end
    end
  end
end
