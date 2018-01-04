rule "FC110", "Script resources should use 'code' property not 'command' property" do
  tags %w{deprecation chef13}
  recipe do |ast|
    script_resources = %w{ bash
                           ksh
                           cash
                           script
                           batch
                           perl
                           python
                           ruby
                           windows_script
                         }
    find_resources(ast, type: script_resources).find_all do |resources|
      resource_attribute(resources, "command")
    end
  end
end
