rule "FC081", "Cookbook depends on the partial_search cookbook" do
  tags %w{chef12}
  recipe do |ast|
    [file_match('metadata.rb')] if declared_dependencies(ast).include?('partial_search')
  end
end
