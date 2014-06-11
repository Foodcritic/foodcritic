module FoodCritic

  # Helpers for asserting that the correct warnings are displayed.
  #
  # Unless the environment variable FC_FORK_PROCESS is set to 'true' then the features will be run in the same process.
  module CommandHelpers

    include MiniTest::Assertions

    attr_writer :assertions
    def assertions
      @assertions ||= 0
    end

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
      'FC021' => 'Resource condition in provider may not behave as expected',
      'FC022' => 'Resource condition within loop may not behave as expected',
      'FC023' => 'Prefer conditional attributes',
      'FC024' => 'Consider adding platform equivalents',
      'FC025' => 'Prefer chef_gem to compile-time gem install',
      'FC026' => 'Conditional execution block attribute contains only string',
      'FC027' => 'Resource sets internal attribute',
      'FC028' => 'Incorrect #platform? usage',
      'FC029' => 'No leading cookbook name in recipe metadata',
      'FC030' => 'Cookbook contains debugger breakpoints',
      'FC031' => 'Cookbook without metadata file',
      'FC032' => 'Invalid notification timing',
      'FC033' => 'Missing template',
      'FC034' => 'Unused template variables',
      'FC037' => 'Invalid notification action',
      'FC038' => 'Invalid resource action',
      'FC039' => 'Node method cannot be accessed with key',
      'FC040' => 'Execute resource used to run git commands',
      'FC041' => 'Execute resource used to run curl or wget commands',
      'FC042' => 'Prefer include_recipe to require_recipe',
      'FC043' => 'Prefer new notification syntax',
      'FC044' => 'Avoid bare attribute keys',
      'FC045' => 'Consider setting cookbook name in metadata',
      'FC046' => 'Attribute assignment uses assign unless nil',
      'FC047' => 'Attribute assignment does not specify precedence',
      'FC048' => 'Prefer Mixlib::ShellOut',
      'FC049' => 'Role name does not match containing file name',
      'FC050' => 'Name includes invalid characters',
      'FC051' => 'Template partials loop indefinitely',
      'FCTEST001' => 'Test Rule'
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
                          :resource => 'resources/site.rb', :libraries => 'libraries/lib.rb'}[options[:file_type]]
      end
      options = {:line => 1, :expect_warning => true, :file => 'recipes/default.rb'}.merge!(options)
      unless options[:file].include?('roles') ||
        options[:file].include?('environments')
          options[:file] = "cookbooks/example/#{options[:file]}"
      end
      if options[:warning_only]
        warning = "#{code}: #{WARNINGS[code]}"
      else
        warning = "#{code}: #{WARNINGS[code]}: #{options[:file]}:#{options[:line]}#{"\n" if ! options[:line].nil?}"
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

    def has_test_warnings?(output)
      output.split("\n").grep(/FC[0-9]+:/).map do |warn|
        File.basename(File.dirname(warn.split(':').take(3).last.strip))
      end.include?('test')
    end

    def man_page_options
      man_path = Pathname.new(__FILE__) + '../../../man/foodcritic.1.ronn'
      option_lines = File.read(man_path).split('## ').find do |s|
        s.start_with?('OPTIONS')
      end.split("\n").select{|o| o.start_with?(' *')}
      option_lines.map do |o|
        o.sub('`[`no-`]`', '').split('`').select{|f| f.include?('-')}
      end.map do |option|
        {:short => option.first.sub(/^-/, ''),
         :long => option.last.sub(/^--/, '')}
      end.sort_by{|o| o[:short]}
    end

    # Assert that the usage message is displayed.
    #
    # @param [Boolean] is_exit_zero The exit code to check for.
    def usage_displayed(is_exit_zero)
      expect_output 'foodcritic [cookbook_paths]'

      usage_options.each do |option|
        expect_usage_option(option[:short], option[:long], option[:description])
      end

      if is_exit_zero
        assert_no_error_occurred
      else
        assert_error_occurred
      end
    end

    def usage_options
      [
        {:short => 'c', :long => 'chef-version VERSION',
         :description => 'Only check against rules valid for this version of Chef.'},

        {:short => 'f', :long => 'epic-fail TAGS',
         :description => "Fail the build based on tags. Use 'any' to fail on all warnings."},

        {:short => 't', :long => 'tags TAGS',
         :description => 'Check against (or exclude ~) rules with the specified tags.'},

        {:short => 'B', :long => 'cookbook-path PATH',
         :description => 'Cookbook path(s) to check.'},

        {:short => 'C', :long => '[no-]context',
         :description => 'Show lines matched against rather than the default summary.'},

        {:short => 'E', :long => 'environment-path PATH',
         :description => 'Environment path(s) to check.'},

        {:short => 'I', :long => 'include PATH',
         :description => 'Additional rule file path(s) to load.'},

        {:short => 'R', :long => 'role-path PATH',
         :description => 'Role path(s) to check.'},

        {:short => 'S', :long => 'search-grammar PATH',
         :description => 'Specify grammar to use when validating search syntax.'},

        {:short => 'V', :long => 'version',
         :description => 'Display the foodcritic version.'},

        {:short => 'X', :long => 'exclude PATH',
         :description => 'Exclude path(s) from being linted.'}

      ]
    end

    def usage_options_for_diff
      usage_options.map do |o|
        {:short => o[:short],
         :long => o[:long].split(' ').first.sub(/^\[no-\]/, '')}
      end.sort_by{|o| o[:short]}
    end

  end

  # Helpers used when features are executed in-process.
  module InProcessHelpers

    # Assert that the output contains the specified warning.
    #
    # @param [String] output The warning to check for.
    def expect_output(output)
      if output.respond_to?(:~)
        @review.must_match(output)
      else
        @review.must_include(output)
      end
    end

    # Assert that the output does not contain the specified warning.
    #
    # @param [String] output The output to check for.
    def expect_no_output(output)
      if output.respond_to?(:~)
        @review.wont_match(output)
      else
        @review.wont_include(output)
      end
    end

    # Assert that an error occurred following a lint check.
    def assert_error_occurred
      @status.wont_equal 0
    end

    # Assert that no error occurred following a lint check.
    def assert_no_error_occurred
      @status.must_equal 0
    end

    # Assert that warnings have not been raised against the test code which
    # should have been excluded from linting.
    def assert_no_test_warnings
      refute has_test_warnings?(@review)
    end

    # Assert that warnings have been raised against the test code which
    # shouldn't have been excluded from linting.
    def assert_test_warnings
      assert has_test_warnings?(@review)
    end

    # Run a lint check with the provided command line arguments.
    #
    # @param [Array] cmd_args The command line arguments.
    def run_lint(cmd_args)
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

  end

  # For use with steps that use bundler and rake. These will always be run
  # via Aruba.
  module BuildHelpers

    # Assert the build outcome
    #
    # @param [Boolean] success True if the build should succeed
    # @param [Array] warnings The warnings expected
    def assert_build_result(success, warnings)
      success ? assert_no_error_occurred : assert_error_occurred
      warnings.each do |code|
        expect_warning(code, :warning_only => true)
      end
    end

    # Assert that warnings have not been raised against the test code which
    # should have been excluded from linting.
    def assert_no_test_warnings
      refute has_test_warnings?(all_output)
    end

    # Assert that warnings have been raised against the test code which
    # shouldn't have been excluded from linting.
    def assert_test_warnings
      assert has_test_warnings?(all_output)
    end

    # The available tasks for this build
    #
    # @return [Array] Task name and description
    def build_tasks
      all_output.split("\n").map do |task|
        next unless task.start_with? 'rake'
        task.split("#").map{|t| t.strip.sub(/^rake /, '')}
      end.compact
    end

    # List the defined Rake tasks
    def list_available_build_tasks
      cd 'cookbooks/example'
      unset_bundler_env_vars
      run_simple 'bundle exec rake -T'
    end

    # Run a build for a Rakefile that uses the lint rake task
    def run_build
      cd 'cookbooks/example'
      run_simple "bundle exec rake", false
    end

    # We want to avoid traversing vendored gems because of the unnecessary
    # performance hit and because gems may contain deeply-nested code which
    # will blow the stack on parsing.
    def vendor_gems
      cd 'cookbooks/example'
      unset_bundler_env_vars
      run_simple 'bundle install --path vendor/bundle'
      cd '../..'
    end

  end

  # Helpers used when features are executed out of process.
  module ArubaHelpers

    include BuildHelpers

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
