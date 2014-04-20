require 'gherkin/tag_expression'

module FoodCritic
  # A warning of a possible issue
  class Warning
    attr_reader :rule, :match, :is_failed

    # Create a new warning.
    #
    #     Warning.new(rule, :filename => 'foo/recipes.default.rb',
    #       :line => 5, :column=> 40)
    #
    def initialize(rule, match = {}, options = {})
      @rule, @match = rule, match
      @is_failed = if options[:fail_tags].empty?
                     false
                   else
                     rule.matches_tags?(options[:fail_tags])
                   end
    end

    # If this warning has failed or not.
    def failed?
      @is_failed
    end
  end

  # The collected warnings (if any) raised against a cookbook tree.
  class Review
    attr_reader :cookbook_paths, :warnings

    def initialize(cookbook_paths, warnings)
      @cookbook_paths = Array(cookbook_paths)
      @warnings = warnings
    end

    # If any of the warnings in this review have failed or not.
    def failed?
      warnings.any? { |w| w.failed? }
    end

    # Returns an array of warnings that are marked as failed.
    def failures
      warnings.select { |w| w.failed? }
    end

    # Returns a string representation of this review. This representation is
    # liable to change.
    def to_s
      # Sorted by filename and line number.
      #
      #     FC123: My rule name: foo/recipes/default.rb
      @warnings.map do |w|
        ["#{w.rule.code}: #{w.rule.name}: #{w.match[:filename]}",
         w.match[:line].to_i]
      end.sort do |x, y|
        x.first == y.first ? x[1] <=> y[1] : x.first <=> y.first
      end.map { |w|"#{w.first}:#{w[1]}" }.uniq.join("\n")
    end
  end

  # A rule to be matched against.
  class Rule
    attr_accessor :code, :name, :applies_to, :cookbook, :attributes, :recipe,
                  :provider, :resource, :metadata, :library, :template, :role,
                  :environment

    attr_writer :tags

    def initialize(code, name)
      @code, @name = code, name
      @tags = [code]
      @applies_to = Proc.new { |version| true }
    end

    # The tags associated with this rule. Rule is always tagged with the tag
    # `any` and the rule code.
    def tags
      ['any'] + @tags
    end

    # Checks the rule tags to see if they match a Gherkin (Cucumber) expression
    def matches_tags?(tag_expr)
      Gherkin::TagExpression.new(tag_expr).evaluate(tags.map do |t|
        Gherkin::Formatter::Model::Tag.new(t, 1)
      end)
    end

    # Returns a string representation of this rule.
    def to_s
      "#{@code}: #{@name}"
    end
  end
end
