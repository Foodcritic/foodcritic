rule "FC101", "Deprecated deploy resource used" do
  tags %w{chef14 deprecated}
  recipe do |ast|
    find_resources(ast, type: "deploy")
  end
end
