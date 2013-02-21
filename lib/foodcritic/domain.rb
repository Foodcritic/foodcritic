module FoodCritic

  # A warning of a possible issue
  class Warning
    attr_reader :rule, :match

    # Create a new warning.
    #
    #     Warning.new(rule, :filename => 'foo/recipes.default.rb',
    #       :line => 5, :column=> 40)
    #
    def initialize(rule, match={})
      @rule, @match = rule, match
    end
  end

  # The collected warnings (if any) raised against a cookbook tree.
  class Review

    attr_reader :cookbook_paths, :warnings

    def initialize(cookbook_paths, warnings, is_failed, ignore_file = nil)
      @cookbook_paths = Array(cookbook_paths)
      @warnings = warnings
      @is_failed = is_failed
      @ignore_file = ignore_file
    end

    # Returns a list of warnings where those that are listed in an ignore file
    # are omitted.
    def quieter_warnings
      # Remove any warnings that match the ignore rules
      @warnings.reject do |w|
        ignore_rules.any? do |code, file, line|

          # If no line is provided in the ignore file, use the warning's line
          # This will ignore the rule across the entire file
          line = line ? line.to_i : w.match[:line]

          same_code = code == w.rule.code
          same_file = file == w.match[:filename]
          same_line = line == w.match[:line]

          same_code && same_file && same_line
        end
      end
    end

    # Provided for backwards compatibility. Deprecated and will be removed in a
    # later version.
    def cookbook_path
      @cookbook_paths.first
    end

    # If this review has failed or not.
    def failed?
      @is_failed
    end

    # Returns a string representation of this review. This representation is
    # liable to change.
    def to_s
      # Sorted by filename and line number.
      #
      #     FC123: My rule name: foo/recipes/default.rb
      warnings_to_display = @ignore_file ? quieter_warnings : @warnings
      warnings_to_display.map do |w|
        ["#{w.rule.code}: #{w.rule.name}: #{w.match[:filename]}",
         w.match[:line].to_i]
      end.sort do |x,y|
        x.first == y.first ? x[1] <=> y[1] : x.first <=> y.first
      end.map{|w|"#{w.first}:#{w[1]}"}.uniq.join("\n")
    end

    private

    # Returns a multi-dimensional array of warnings to ignore in the review.
    #
    #     [["FC004", "cookbooks/foo/recipes/default.rb", "22"],
    #      ["FC014", "cookbooks/bar/recipes/qux.rb", "37"],
    #      ["FC017", "cookbooks/baz/providers/quux.rb", "1"]]
    def ignore_rules
      # Read the ignore file
      ignore = File.open(@ignore_file).readlines
      # Strip out comments and blank lines
      ignore.reject! {|line| line !~ /^FC/}
      # Split the line into its component parts
      ignore.map! {|rule| rule.chomp.split(/: ?/)}
      # Throw away the rule name
      ignore.each {|rule| rule.delete_at(1)}
    end
  end

  # A rule to be matched against.
  class Rule
    attr_accessor :code, :name, :applies_to, :cookbook, :attributes, :recipe,
      :provider, :resource, :metadata, :library, :template

    attr_writer :tags

    def initialize(code, name)
      @code, @name = code, name
      @tags = [code]
      @applies_to = Proc.new {|version| true}
    end

    # The tags associated with this rule. Rule is always tagged with the tag
    # `any` and the rule code.
    def tags
      ['any'] + @tags
    end

    # Returns a string representation of this rule.
    def to_s
      "#{@code}: #{@name}"
    end
  end

end
