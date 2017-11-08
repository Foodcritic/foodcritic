rule "FC098", "Deprecated Chef::Mixin::RecipeDefinitionDSLCore mixin used" do
  tags %w{chef14 deprecated}
  recipe do |ast|
    # include Chef::Mixin::RecipeDefinitionDSLCore
    ast.xpath('//const_path_ref/const[@value="RecipeDefinitionDSLCore"]/..//const[@value="Mixin"]/..//const[@value="Chef"]')
  end
end
