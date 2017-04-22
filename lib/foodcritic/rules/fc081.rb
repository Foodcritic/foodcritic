rule "FC081", "Cookbook depends on the partial_search cookbook" do
  tags %w{chef12}
  metadata do |ast, filename|
    [file_match(filename)] if declared_dependencies(ast).include?('partial_search')
  end
end
