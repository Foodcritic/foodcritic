rule "FC042", "Prefer include_recipe to require_recipe" do
  tags %w{correctness deprecated}
  recipe do |ast|
    ast.xpath('//command[ident/@value="require_recipe"]')
  end
end
