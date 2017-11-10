rule "FC105", "Deprecated erl_call resource used" do
  tags %w{chef14 deprecated}
  recipe do |ast|
    find_resources(ast, type: "erl_call")
  end
end
