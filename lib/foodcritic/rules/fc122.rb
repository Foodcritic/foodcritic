rule "FC122", "Use the build_essential resource instead of the recipe" do
  tags %w{correctness}
  recipe do |ast|
    ast.xpath("//command[ident/@value = 'include_recipe']/descendant::tstring_content[@value='build-essential' or @value='build-essential::default']")
  end
end
