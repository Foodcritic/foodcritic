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
      warnings = []; last_dir = nil
      tag_expr = Gherkin::TagExpression.new(options[:tags])
      files_to_process(cookbook_path).each do |file|
        current_dir = Pathname.new(File.join(File.dirname(file), '..')).cleanpath
        ast = read_file(file)
        @rules.select{|rule| tag_expr.eval(rule.tags)}.each do |rule|
          matches = []
          if last_dir != current_dir and rule.cookbook.respond_to?(:yield)
            cookbook_matches = rule.cookbook.yield(current_dir)
            matches += cookbook_matches if cookbook_matches.respond_to?(:each)
          end
          if rule.recipe.respond_to?(:yield)
            recipe_matches = rule.recipe.yield(ast, file)
            matches += recipe_matches if recipe_matches.respond_to?(:each)
          end
          matches.each{|match| warnings << Warning.new(rule, {:filename => file}.merge(match))}
        end
        last_dir = current_dir
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