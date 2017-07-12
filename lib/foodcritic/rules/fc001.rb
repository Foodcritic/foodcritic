rule "FC001",
     "Use strings in preference to symbols to access node attributes" do
  tags %w{style attributes}
  recipe do |ast|
    # node.run_state is not actually an attribute so ignore that
    attribute_access(ast, type: :symbol, ignore: "run_state")
  end
end
