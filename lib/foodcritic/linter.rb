require 'ripper'
require 'gherkin/tag_expression'

module FoodCritic

  # The main entry point for linting your Chef cookbooks.
  class Linter

    include FoodCritic::Helpers

    # Create a new Linter, loading any defined rules.
    def initialize
      load_rules
    end

    # Review the cookbooks at the provided path, identifying potential improvements.
    #
    # @param [String] cookbook_path The file path to an individual cookbook directory
    # @param [Hash] options Options to apply to the linting
    # @option options [Array] tags The tags to filter rules based on
    # @return [FoodCritic::Review] A review of your cookbooks, with any warnings issued.
    def check(cookbook_path, options)
      warnings = []
      tag_expr = Gherkin::TagExpression.new(options[:tags])
      files_to_process(cookbook_path).each do |file|
        ast = read_file(file)
        @rules.each do |rule|
          if tag_expr.eval(rule.tags)
            matches = rule.recipe.yield(ast, file)
            matches.each{|match| warnings << Warning.new(rule, {:filename => file}.merge(match))} unless matches.nil?
          end
        end
      end
      Review.new(warnings)
    end

    private

    # Load the rules from the (fairly unnecessary) DSL.
    def load_rules
      @rules = RuleDsl.load(File.join(File.dirname(__FILE__), 'rules.rb'))
    end

    # Return the files within a cookbook tree that we are interested in trying to match rules against.
    #
    # @param [String] dir The cookbook directory
    # @return [Array] The files underneath the provided directory to be processed.
    def files_to_process(dir)
      return [dir] unless File.directory? dir
      Dir.glob(File.join(dir, '{attributes,recipes}/*.rb')) + Dir.glob(File.join(dir, '*/{attributes,recipes}/*.rb'))
    end

  end
end