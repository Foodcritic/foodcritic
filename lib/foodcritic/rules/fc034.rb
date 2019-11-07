rule "FC034", "Unused template variables" do
  tags %w{correctness templates}
  recipe do |ast, filename|
    Array(resource_attributes_by_type(ast)["template"]).select do |t|
      t["variables"] && t["variables"].respond_to?(:xpath)
    end.map do |resource|
      all_templates = template_paths(filename)
      template_paths = all_templates.select do |path|
        File.basename(path) == template_file(resource)
      end
      next unless template_paths.any?

      passed_vars = resource["variables"].xpath(
        "symbol/ident/@value"
      ).map(&:to_s)

      unused_vars_exist = template_paths.all? do |template_path|
        begin
          template_vars = templates_included(
            all_templates, template_path
          ).map do |template|
            read_ast(template).xpath("//var_ref/ivar/@value").map do |v|
              v.to_s.sub(/^@/, "")
            end
          end.flatten
          ! (passed_vars - template_vars).empty?
        rescue RecursedTooFarError
          false
        end
      end
      file_match(template_paths.first) if unused_vars_exist
    end.compact
  end
end
