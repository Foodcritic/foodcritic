rule "FC081", "Cookbook depends on the deprecated partial_search cookbook" do
  tags %w{chef12 deprecated}
  metadata do |ast, filename|
    [file_match(filename)] if declared_dependencies(ast).include?("partial_search")
  end
end
