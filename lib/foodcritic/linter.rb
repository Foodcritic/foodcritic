require 'optparse'
require 'ripper'
require 'gherkin/tag_expression'

module FoodCritic

  # The main entry point for linting your Chef cookbooks.
  class Linter

    include FoodCritic::Helpers

    # Perform option parsing from the provided arguments and do a lint check based on those arguments.
    #
    # @param [Array] args The command-line arguments to parse
    # @return [Array] Pair - the first item is string output, the second is the exit code.
    def self.check(args)
      options = {}
      options[:tags] = []
      parser = OptionParser.new do |opts|
        opts.banner = 'foodcritic [cookbook_path]'
        opts.on("-r", "--[no-]repl", "Drop into a REPL for interactive rule editing.") {|r|options[:repl] = r}
        opts.on("-t", "--tags TAGS", "Only check against rules with the specified tags.") {|t|options[:tags] << t}
      end

      return [parser.help, 0] if args.length == 1 and args.first == '--help'

      parser.parse!(args)

      if args.length == 1 and Dir.exists?(args[0])
        [FoodCritic::Linter.new.check(args[0], options), 0]
      else
        [parser.help, 2]
      end
    end

    # Create a new Linter.
    def initialize

    end

    # Review the cookbooks at the provided path, identifying potential improvements.
    #
    # @param [String] cookbook_path The file path to an individual cookbook directory
    # @param [Hash] options Options to apply to the linting
    # @option options [Array] tags The tags to filter rules based on
    # @return [FoodCritic::Review] A review of your cookbooks, with any warnings issued.
    def check(cookbook_path, options)
      @last_cookbook_path = cookbook_path
      @last_options = options
      load_rules unless defined? @rules
      warnings = []; last_dir = nil
      tag_expr = Gherkin::TagExpression.new(options[:tags])
      files_to_process(cookbook_path).each do |file|
        cookbook_dir = Pathname.new(File.join(File.dirname(file), '..')).cleanpath
        ast = read_file(file)
        @rules.select{|rule| tag_expr.eval(rule.tags)}.each do |rule|
          rule_matches = matches(rule.recipe, ast, file)
          rule_matches += matches(rule.provider, ast, file) if File.basename(File.dirname(file)) == 'providers'
          rule_matches += matches(rule.cookbook, cookbook_dir) if last_dir != cookbook_dir
          rule_matches.each{|match| warnings << Warning.new(rule, {:filename => file}.merge(match))}
        end
        last_dir = cookbook_dir
      end
      @review = Review.new(warnings)
      binding.pry if options[:repl]
      @review
    end

    def recheck
      check(@last_cookbook_path, @last_options)
    end

    # Load the rules from the (fairly unnecessary) DSL.
    def load_rules
      @rules = RuleDsl.load(File.join(File.dirname(__FILE__), 'rules.rb'), @last_options[:repl])
    end

    alias_method :reset_rules, :load_rules

    def review
      @review
    end

    private

    # Invoke the DSL method with the provided parameters.
    #
    # @param [Proc] match_method Proc to invoke
    # @param params Parameters for the proc
    # @return [Array] The returned matches
    def matches(match_method, *params)
      return [] unless match_method.respond_to?(:yield)
      matches = match_method.yield(*params)
      matches.respond_to?(:each) ? matches : []
    end

    # Return the files within a cookbook tree that we are interested in trying to match rules against.
    #
    # @param [String] dir The cookbook directory
    # @return [Array] The files underneath the provided directory to be processed.
    def files_to_process(dir)
      return [dir] unless File.directory? dir
      Dir.glob(File.join(dir, '{attributes,providers,recipes}/*.rb')) +
          Dir.glob(File.join(dir, '*/{attributes,providers,recipes}/*.rb'))
    end

  end
end