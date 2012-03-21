module FoodCritic

  # Helpers for asserting that the correct warnings are displayed.
  #
  # Unless the environment variable FC_FORK_PROCESS is set to 'true' then the features will be run in the same process.
  module CommandHelpers

    # The warning codes and messages displayed to the end user.
    WARNINGS = {
      'FC001' => 'Use strings in preference to symbols to access node attributes',
      'FC002' => 'Avoid string interpolation where not required',
      'FC003' => 'Check whether you are running with chef server before using server-specific features',
      'FC004' => 'Use a service resource to start and stop services',
      'FC005' => 'Avoid repetition of resource declarations',
      'FC006' => 'Mode should be quoted or fully specified when setting file permissions',
      'FC007' => 'Ensure recipe dependencies are reflected in cookbook metadata',
      'FC008' => 'Generated cookbook metadata needs updating',
      'FC009' => 'Resource attribute not recognised',
      'FC010' => 'Invalid search syntax',
      'FC011' => 'Missing README in markdown format',
      'FC012' => 'Use Markdown for README rather than RDoc',
      'FC013' => 'Use file_cache_path rather than hard-coding tmp paths',
      'FC014' => 'Consider extracting long ruby_block to library',
      'FC015' => 'Consider converting definition to a LWRP',
      'FC016' => 'LWRP does not declare a default action',
      'FC017' => 'LWRP does not notify when updated',
      'FC018' => 'LWRP uses deprecated notification syntax',
      'FC019' => 'Access node attributes in a consistent manner',
      'FC020' => 'Conditional execution string attribute looks like Ruby',
      'FC021' => 'Resource condition in provider may not behave as expected',
      'FC022' => 'Resource condition within loop may not behave as expected',
      'FC023' => 'Prefer conditional attributes'
    }

    # If the cucumber features should run foodcritic in the same process or spawn a separate process.
    def self.running_in_process?
      ! (ENV.has_key?('FC_FORK_PROCESS') and ENV['FC_FORK_PROCESS'] == true.to_s)
    end

    # Capture an error expected when calling a command.
    def capture_error
      begin
        yield
        @error = all_output unless last_exit_status == 0
      rescue => @error
      end
    end

    # Return the last error captured
    #
    # @return [String] The last error captured
    def last_error
      @error.respond_to?(:message) ? @error.message : @error
    end

    # Expect a line of context
    #
    # @param [Number] line_no The line number
    # @param [String] text The text of the matching line
    def expect_line_shown(line_no, text)
      expect_output %r{^ +#{Regexp.escape(line_no.to_s)}\|#{Regexp.escape(text)}$}
    end

    # Expect a warning to be included in the command output.
    #
    # @param [String] code The warning code to check for.
    # @param [Hash] options The warning options.
    # @option options [Integer] :line The line number the warning should appear on - nil for any line.
    # @option options [Boolean] :expect_warning If false then assert that a warning is NOT present
    # @option options [String] :file The path to the file the warning should be raised against
    # @option options [Symbol] :file_type Alternative to specifying file name. One of: :attributes, :definition,
    #   :metadata, :provider, :resource
    def expect_warning(code, options={})
      if options.has_key?(:file_type)
        options[:file] = {:attributes => 'attributes/default.rb', :definition => 'definitions/apache_site.rb',
                          :metadata => 'metadata.rb', :provider => 'providers/site.rb',
                          :resource => 'resources/site.rb'}[options[:file_type]]
      end
      options = {:line => 1, :expect_warning => true, :file => 'recipes/default.rb'}.merge!(options)
      if options[:warning_only]
        warning = "#{code}: #{WARNINGS[code]}"
      else
        warning = "#{code}: #{WARNINGS[code]}: cookbooks/example/#{options[:file]}:#{options[:line]}#{"\n" if ! options[:line].nil?}"
      end
      options[:expect_warning] ? expect_output(warning) : expect_no_output(warning)
    end

    # Expect a warning not to be included in the command output.
    #
    # @see CommandHelpers#expect_warning
    def expect_no_warning(code, options={:expect_warning => false})
      expect_warning(code, options)
    end

    # Expect a command line option / switch to be included in the usage.
    #
    # @param [String] short_switch The short version of the switch
    # @param [String] long_switch The long descriptive version of the switch
    # @param [String] description The description of the switch
    def expect_usage_option(short_switch, long_switch, description)
      expected_switch = "-#{Regexp.escape(short_switch)}, --#{Regexp.escape(long_switch)}[ ]+#{Regexp.escape(description)}"
      expect_output(Regexp.new(expected_switch))
    end

    # Assert that the usage message is displayed.
    #
    # @param [Boolean] is_exit_zero The exit code to check for.
    def usage_displayed(is_exit_zero)
      expect_output 'foodcritic [cookbook_path]'
      expect_usage_option('f', 'epic-fail TAGS', 'Fail the build if any of the specified tags are matched.')
      expect_usage_option('r', '[no-]repl', 'Drop into a REPL for interactive rule editing.')
      expect_usage_option('t', 'tags TAGS', 'Only check against rules with the specified tags.')
      expect_usage_option('C', '[no-]context', 'Show lines matched against rather than the default summary.')
      expect_usage_option('I', 'include PATH', 'Additional rule file path(s) to load.')
      expect_usage_option('S', 'search-grammar PATH', 'Specify grammar to use when validating search syntax.')
      expect_usage_option('V', 'version', 'Display version.')
      if is_exit_zero
        assert_no_error_occurred
      else
        assert_error_occurred
      end
    end

  end

  # Helpers used when features are executed in-process.
  module InProcessHelpers

    # Assert that the output contains the specified warning.
    #
    # @param [String] output The warning to check for.
    def expect_output(output)
      if output.respond_to?(:~)
        @review.should match(output)
      else
        @review.should include(output)
      end
    end

    # Assert that the output does not contain the specified warning.
    #
    # @param [String] output The output to check for.
    def expect_no_output(output)
      if output.respond_to?(:~)
        @review.should_not match(output)
      else
        @review.should_not include(output)
      end
    end

    # Assert that an error occurred following a lint check.
    def assert_error_occurred
      @status.should_not == 0
    end

    # Assert that no error occurred following a lint check.
    def assert_no_error_occurred
      @status.should == 0
    end

    # Run a lint check with the provided command line arguments.
    #
    # @param [Array] cmd_args The command line arguments.
    def run_lint(cmd_args)
      cmd_args.unshift '--repl' if with_repl?
      in_current_dir do
        show_context = cmd_args.include?('-C')
        review, @status = FoodCritic::Linter.check(CommandLine.new(cmd_args))
        @review =
          if review.nil? || (review.respond_to?(:warnings) && review.warnings.empty?)
            ''
          elsif show_context
            ContextOutput.new.output(review)
          else
            "#{review.to_s}\n"
          end
      end
    end

    def with_repl?
      (ENV.has_key?('FC_REPL') and ENV['FC_REPL'] == true.to_s)
    end

  end

  # Helpers used when features are executed out of process.
  module ArubaHelpers

    # Assert that the output contains the specified warning.
    #
    # @param [String] output The output to check for.
    def expect_output(output)
      if output.respond_to?(:~)
        assert_matching_output(output.to_s, all_output)
      else
        assert_partial_output(output, all_output)
      end
    end

    # Assert that the output does not contain the specified warning.
    #
    # @param [String] output The output to check for.
    def expect_no_output(output)
      if output.respond_to?(:~)
        assert_matching_output('^((?!#{output}).)*$', all_output)
      else
        assert_no_partial_output(output, all_output)
      end
    end

    # Assert that an error occurred following a lint check.
    def assert_error_occurred
      assert_not_exit_status 0
    end

    # Assert that no error occurred following a lint check.
    def assert_no_error_occurred
      assert_exit_status(0)
    end

    # Run a lint check with the provided command line arguments.
    #
    # @param [Array] cmd_args The command line arguments.
    def run_lint(cmd_args)
      set_env 'RAK_TEST', true.to_s
      run_simple(unescape("foodcritic #{cmd_args.join(' ')}"), false)
    end
  end

end

World(FoodCritic::CommandHelpers)
if FoodCritic::CommandHelpers.running_in_process?
  World(FoodCritic::InProcessHelpers)
else
  World(FoodCritic::ArubaHelpers)
end
