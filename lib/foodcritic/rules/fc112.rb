rule "FC112", "Resource using deprecated dsl_name method" do
  tags %w{deprecated chef13}
  recipe do |ast|
    ast.xpath("//call/ident[@value='dsl_name']")
  end
end
