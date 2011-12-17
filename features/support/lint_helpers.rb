module FoodCritic

  module Helpers

    def write_recipe(content)
      write_file 'cookbooks/example/recipes/default.rb', content
    end

    def write_attributes(content)
      write_file 'cookbooks/example/attributes/default.rb', content
    end

    def write_definition(name, content)
      write_file "cookbooks/example/definitions/#{name}.rb", content
    end

    def write_metadata(content)
      write_file 'cookbooks/example/metadata.rb', content
    end

    def write_resource(name, content)
      write_file "cookbooks/example/resources/#{name}.rb", content
    end

    def write_provider(name, content)
      write_file "cookbooks/example/providers/#{name}.rb", content
    end

    def run_lint(cmd_args)
      run_simple(unescape("foodcritic #{cmd_args} cookbooks/example/"), false)
    end

    def expect_warning(code, options={})
      opt = {:line => 1, :expect_warning => true, :file => 'cookbooks/example/recipes/default.rb'}.merge!(options)
      warning_text = case code
                       when 'FC001' then
                         'Use strings in preference to symbols to access node attributes'
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
                       when 'FC007' then
                         'Ensure recipe dependencies are reflected in cookbook metadata'
                       when 'FC008' then
                         'Generated cookbook metadata needs updating'
                       when 'FC009' then
                         'Resource attribute not recognised'
                       when 'FC010' then
                          'Invalid search syntax'
                       when 'FC011' then
                          'Missing README in markdown format'
                       when 'FC012' then
                          'Use Markdown for README rather than RDoc'
                       when 'FC013' then
                          'Use file_cache_path rather than hard-coding tmp paths'
                       when 'FC014' then
                          'Consider extracting long ruby_block to library'
                       when 'FC015' then
                          'Consider converting definition to a LWRP'
                       when 'FC016' then
                          'LWRP does not declare a default action'
                       when 'FC017' then
                          'LWRP does not notify when updated'
                     end

      if opt[:expect_warning]
        assert_partial_output("#{code}: #{warning_text}: #{opt[:file]}:#{opt[:line]}#{"\n" if ! opt[:line].nil?}", all_output)
      else
        assert_no_partial_output("#{code}: #{warning_text}: #{opt[:file]}:#{opt[:line]}#{"\n" if ! opt[:line].nil?}", all_output)
      end
    end

    def expect_no_warning(code, options={:expect_warning => false})
      expect_warning(code, options)
    end
  end

end

World(FoodCritic::Helpers)