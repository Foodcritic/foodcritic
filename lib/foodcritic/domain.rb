module FoodCritic

  # A warning of a possible issue
  class Warning
    attr_reader :rule, :match

    # Create a new warning
    #
    # @param [FoodCritic::Rule] rule The rule which raised this warning
    # @param [Hash] match The match data
    # @option match [String] :filename The filename the warning was raised against
    # @option match [Integer] :line The identified line
    # @option match [Integer] :column The identified column
    def initialize(rule, match={})
      @rule, @match = rule, match
    end
  end

  # The collected warnings (if any) raised against a cookbook tree.
  class Review

    attr_reader :cookbook_path, :warnings

    # Create a new review
    #
    # @param [String] cookbook_path The path this review was performed against
    # @param [Array] warnings The warnings raised in this review
    # @param [Boolean] is_failed Have warnings been raised that mean this should be considered failed?
    def initialize(cookbook_path, warnings, is_failed)
      @cookbook_path = cookbook_path
      @warnings = warnings
      @is_failed = is_failed
    end

    # If this review has failed or not.
    #
    # @return [Boolean] True if this review has failed.
    def failed?
      @is_failed
    end

    # Returns a string representation of this review.
    #
    # @return [String] Review as a string, this representation is liable to change.
    def to_s
      @warnings.map{|w|["#{w.rule.code}: #{w.rule.name}: #{w.match[:filename]}", w.match[:line].to_i]}.sort do |x,y|
        x.first == y.first ? x[1] <=> y[1] : x.first <=> y.first
      end.map{|w|"#{w.first}:#{w[1]}"}.uniq.join("\n")
    end
  end

  # A rule to be matched against.
  class Rule
    attr_accessor :code, :name, :cookbook, :recipe, :provider, :resource, :tags

    # Create a new rule
    #
    # @param [String] code The short unique identifier for this rule, e.g. 'FC001'
    # @param [String] name The short descriptive name of this rule presented to the end user.
    def initialize(code, name)
      @code, @name = code, name
      @tags = [code]
    end

    # Returns a string representation of this rule.
    #
    # @return [String] Rule as a string.
    def to_s
      "#{@code}: #{@name}"
    end
  end

end