rule "FC051", "Template partials loop indefinitely" do
  tags %w{correctness templates}
  recipe do |_, filename|
    cbk_templates = template_paths(filename)

    cbk_templates.select do |template|
      begin
        templates_included(cbk_templates, template)
        false
      rescue RecursedTooFarError
        true
      end
    end.map { |t| file_match(t) }
  end
end
