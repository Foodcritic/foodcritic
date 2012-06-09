require 'optparse'
require 'ripper'
require 'rubygems'
require 'gherkin/tag_expression'
require 'set'

module FoodCritic

  # The main entry point for linting your Chef cookbooks.
  class Linter

    include FoodCritic::Api

    # The default version that will be used to determine relevant rules
    DEFAULT_CHEF_VERSION = "0.10.10"

    # Perform option parsing from the provided arguments and do a lint check
    # based on those arguments.
    #
    # @param [Array] args The command-line arguments to parse
    # @return [Array] Pair - the first item is string output, the second is the
    #   exit code.
    def self.check(cmd_line)
      return [cmd_line.help, 0] if cmd_line.show_help?
      return [cmd_line.version, 0] if cmd_line.show_version?
      if ! cmd_line.valid_grammar?
        [cmd_line.help, 4]
      elsif cmd_line.valid_paths?
        review = FoodCritic::Linter.new.check(cmd_line.cookbook_paths,
          cmd_line.options)
        [review, review.failed? ? 3 : 0]
      else
        [cmd_line.help, 2]
      end
    end

    # Create a new Linter.
    def initialize

    end

    # Review the cookbooks at the provided path, identifying potential
    # improvements.
    #
    # @param [Array] cookbook_paths The file path(s) to the individual
    #   cookbook(s) being checked
    # @param [Hash] options Options to apply to the linting
    # @option options [Array] tags The tags to filter rules based on
    # @option options [Array] fail_tags The tags to fail the build on
    # @return [FoodCritic::Review] A review of your cookbooks, with any
    #   warnings issued.
    def check(cookbook_paths, options)
      raise ArgumentError, "Cookbook paths are required" if cookbook_paths.nil?
      @last_cookbook_paths, @last_options = cookbook_paths, options
      load_rules unless defined? @rules
      warnings = []; last_dir = nil; matched_rule_tags = Set.new

      active_rules = @rules.select do |rule|
        matching_tags?(options[:tags], rule.tags) and
        applies_to_version?(rule, options[:chef_version] || DEFAULT_CHEF_VERSION)
      end
      files_to_process(cookbook_paths).each do |file|
        cookbook_dir = Pathname.new(
          File.join(File.dirname(file), '..')).cleanpath
        ast = read_ast(file)
        active_rules.each do |rule|
          rule_matches = matches(rule.recipe, ast, file)
          if File.basename(File.dirname(file)) == 'providers'
            rule_matches += matches(rule.provider, ast, file)
          end
          if File.basename(File.dirname(file)) == 'resources'
            rule_matches += matches(rule.resource, ast, file)
          end
          if last_dir != cookbook_dir
            rule_matches += matches(rule.cookbook, cookbook_dir)
          end
          rule_matches.each do |match|
            warnings << Warning.new(rule, {:filename => file}.merge(match))
            matched_rule_tags << rule.tags
          end
        end
        last_dir = cookbook_dir
      end

      @review = Review.new(cookbook_paths, warnings,
                  should_fail_build?(options[:fail_tags], matched_rule_tags))

      binding.pry if options[:repl]
      @review
    end

    # Convenience method to repeat the last check. Intended to be used from the
    # REPL.
    def recheck
      check(@last_cookbook_paths, @last_options)
    end

    # Load the rules from the (fairly unnecessary) DSL.
    def load_rules
      @rules = RuleDsl.load([File.join(File.dirname(__FILE__), 'rules.rb')] +
        @last_options[:include_rules], @last_options[:repl])
    end

    alias_method :reset_rules, :load_rules

    # Convenience method to retrieve the last review. Intended to be used from
    # the REPL.
    #
    # @return [Review] The last review performed.
    def review
      @review
    end

    private

    # Some rules are version specific.
    #
    # @param [FoodCritic::Rule] rule The rule determine applicability for
    # @param [String] version The version of Chef
    # @return [Boolean] True if the rule applies to this version of Chef
    def applies_to_version?(rule, version)
      return true unless version
      rule.applies_to.yield(Gem::Version.create(version))
    end

    # Invoke the DSL method with the provided parameters.
    #
    # @param [Proc] match_method Proc to invoke
    # @param params Parameters for the proc
    # @return [Array] The returned matches
    def matches(match_method, *params)
      return [] unless match_method.respond_to?(:yield)
      matches = match_method.yield(*params)
      return [] unless matches.respond_to?(:each)
      matches.map do |m|
        if m.respond_to?(:node_name)
          match(m)
        elsif m.respond_to?(:xpath)
          m.to_a.map{|m| match(m)}
        else
          m
        end
      end.flatten
    end

    # Return the files within a cookbook tree that we are interested in trying
    # to match rules against.
    #
    # @param [Array<String>] dirs The cookbook path(s)
    # @return [Array] The files underneath the provided paths to be
    #   processed.
    def files_to_process(dirs)
      files = []

      dirs.each do |dir|
        if File.directory? dir
          cookbook_glob = '{attributes,providers,recipes,resources}/*.rb'
          files += Dir.glob(File.join(dir, cookbook_glob)) +
            Dir.glob(File.join(dir, "*/#{cookbook_glob}"))
        else
          files << dir
        end
      end

      files
    end

    # Whether to fail the build.
    #
    # @param [Array] fail_tags The tags that should cause the build to fail, or
    #   special value 'any' for any tag.
    # @param [Set] matched_tags The tags of warnings we have matches for
    # @return [Boolean] True if the build should be failed
    def should_fail_build?(fail_tags, matched_tags)
      return false if fail_tags.empty?
      matched_tags.any?{|tags| matching_tags?(fail_tags, tags)}
    end

    # Evaluate the specified tags
    #
    # @param [Array] tag_expr Tag expressions
    # @param [Array] tags Tags to match against
    # @return [Boolean] True if the tags match
    def matching_tags?(tag_expr, tags)
      Gherkin::TagExpression.new(tag_expr).eval(tags.map do |t|
        Gherkin::Formatter::Model::Tag.new(t, 1)
      end)
    end

  end
end
