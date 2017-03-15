rule "FC007", "Ensure recipe dependencies are reflected in cookbook metadata" do
  tags %w{correctness metadata}
  recipe do |ast, filename|
    metadata_path = Pathname.new(
      File.join(File.dirname(filename), "..", "metadata.rb")).cleanpath
    next unless File.exist? metadata_path
    actual_included = included_recipes(ast, with_partial_names: false)
    undeclared = actual_included.keys.map do |recipe|
      recipe.split("::").first
    end - [cookbook_name(filename)] -
      declared_dependencies(read_ast(metadata_path))
    actual_included.map do |recipe, include_stmts|
      if undeclared.include?(recipe) ||
          undeclared.any? { |u| recipe.start_with?("#{u}::") }
        include_stmts
      end
    end.flatten.compact
  end
end
