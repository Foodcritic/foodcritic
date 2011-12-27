module FoodCritic

  module CommandHelpers

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
      'FC018' => 'LWRP uses deprecated notification syntax'
    }

    def expect_warning(code, options={})
      if options.has_key?(:file_type)
        options[:file] = {:attributes => 'attributes/default.rb', :definition => 'definitions/apache_site.rb',
                          :metadata => 'metadata.rb', :provider => 'providers/site.rb'}[options[:file_type]]
      end
      options = {:line => 1, :expect_warning => true, :file => 'recipes/default.rb'}.merge!(options)
      warning = "#{code}: #{WARNINGS[code]}: cookbooks/example/#{options[:file]}:#{options[:line]}#{"\n" if ! options[:line].nil?}"
      options[:expect_warning] ? assert_partial_output(warning, all_output) : assert_no_partial_output(warning, all_output)
    end

    def expect_no_warning(code, options={:expect_warning => false})
      expect_warning(code, options)
    end

    def run_lint(cmd_args)
      run_simple(unescape("foodcritic #{cmd_args} cookbooks/example/"), false)
    end

    def usage_displayed(is_exit_zero)
      assert_partial_output 'foodcritic [cookbook_path]', all_output
      assert_matching_output('( )+-t, --tags TAGS( )+Only check against rules with the specified tags.', all_output)
      if is_exit_zero
        assert_exit_status 0
      else
        assert_not_exit_status 0
      end
    end
  end
end

World(FoodCritic::CommandHelpers)
