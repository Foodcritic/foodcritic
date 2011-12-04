module FoodCritic

  module Helpers

    def write_recipe(content)
      write_file 'cookbooks/example/recipes/default.rb', content
    end

    def run_lint
      run_simple(unescape('foodcritic cookbooks/example/'), false)
    end

    def expect_warning(code, options={})
      opt = {:line => 1, :expect_warning => true, :file => 'cookbooks/example/recipes/default.rb'}.merge!(options)
      warning_text = case code
                       when 'FC002' then
                         'Avoid string interpolation where not required'
                       when 'FC003' then
                         'Check whether you are running with chef server before using server-specific features'
                       when 'FC004' then
                         'Use a service resource to start and stop services'
                       when 'FC005' then
                         'Avoid repetition of resource declarations'
                       when 'FC006' then
                         'Mode should be quoted or fully specified when setting file permissions'
                     end

      if opt[:expect_warning]
        assert_partial_output("#{code}: #{warning_text}: #{opt[:file]}:#{opt[:line]}\n", all_output)
      else
        assert_no_partial_output("#{code}: #{warning_text}: #{opt[:file]}:#{opt[:line]}\n", all_output)
      end
    end

    def expect_no_warning(code, options={:expect_warning => false})
      expect_warning(code, options)
    end
  end

end

World(FoodCritic::Helpers)