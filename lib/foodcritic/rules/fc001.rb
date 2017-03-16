rule "FC001",
     "Use strings in preference to symbols to access node attributes" do
  tags %w{style attributes}
  recipe do |ast|
    attribute_access(ast, type: :symbol)
  end
end
