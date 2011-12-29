module FoodCritic

  # Helper REPL methods for use in your steps.
  module ReplHelpers

    # Define a new rule in an interactive session at the REPL.
    #
    # @param [String] code The new rule code.
    # @param [String] name The new rule name.
    # @param [Hash] options Options for the session.
    # @option options [Boolean] :reset_rules If the set of existing rules should be reloaded.
    # @option options [Boolean] :with_binding If the rule should be interactively modified through its own binding.
    # @option options [String] :rule_match_string The string node text to match on.
    def repl_define_rule(code, name, options={})
      options = options.merge!(options)

      rule_changes = %Q{
        throw :breakout, 0
        Helpers.instance_methods.sort
        ast.to_xml
        throw :breakout, 0
        reset_rules
        rule "#{code}", "#{name}" do
          recipe do |ast|
            ast.xpath("//tstring_content[@value='#{options[:rule_match_string]}']").map{|n| match(n)}
          end
        end
        throw :breakout, 0
        recheck
        review
        exit
      }

      pry_session %Q{
        rule "#{code}", "#{name}" do
          recipe do |ast|
            #{'binding.pry' if options[:with_binding]}
          end
        end
        #{"throw :breakout, 0\nreset_rules" if options[:reset_rules]}
        rules
        #{rule_changes if options[:with_binding]}
        exit
      }
    end

    # Was the specified rule shown in the list of rules during the interactive session?
    #
    # @param [String] code The new rule code.
    # @param [String] name The new rule name.
    # @return [Boolean] True if the rule was shown.
    def repl_rule_exists?(code, name)
      @pry_output.include? "#{code}: #{name}"
    end

    # Was the specified rule shown in the list of matching rules when reviewing matches?
    #
    # @param [String] code The new rule code.
    # @param [String] name The new rule name.
    # @return [Boolean] True if the rule was shown.
    def repl_review_includes_match?(code, name)
      @pry_output.include? "#{code}: #{name}: cookbooks/example/recipes/default.rb:1"
    end

    # Were the DSL helper methods available to the rule author when in the context of the rule?
    #
    # @return [Boolean] True if standard helper methods were available.
    def repl_helper_methods_available?
      %w{cookbook_name included_recipes resource_name}.all? {|helper_method| @pry_output.include?(helper_method)}
    end

    # Was the AST available to the rule author when in the context of the rule?
    #
    # @param [String] tstr The string node text expected to be in the AST.
    # @return [Boolean] True if the AST was available.
    def repl_ast_available?(tstr)
      ['tstring_content', tstr].all? {|ast_output| @pry_output.include?(ast_output)}
    end

    private

    # Redirect Pry input and output for capturing.
    #
    # @param [StringIO] new_in Where to read input from.
    # @return [StringIO] The collected output.
    def pry_capture_output(new_in)
      new_out = StringIO.new
      old_in, old_out = Pry.input, Pry.output
      Pry.input, Pry.output = new_in, new_out

      begin
        yield
      ensure
        Pry.input, Pry.output = old_in, old_out
      end
      new_out
    end

    # Run a foodcritic pry session.
    #
    # @param [String] commands The commands to execute.
    def pry_session(commands)
      Pry.color = false
      Pry.pager = false

      result = pry_capture_output(StringIO.new(commands)) do
        begin
          run_lint(['-r', 'cookbooks/example'])
        rescue SystemExit
        end
      end
      @pry_output = result.string
    end

  end

end

World(FoodCritic::ReplHelpers)