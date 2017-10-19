rule "FC098", "Deprecated Chef::Mixin::RecipeDefinitionDSLCore mixin used" do
  tags %w{chef14 deprecated}
  def recipe_def_mixin(ast)
    # include Chef::Mixin::RecipeDefinitionDSLCore
    ast.xpath('//const_path_ref/const[@value="RecipeDefinitionDSLCore"]/..//const[@value="Mixin"]/..//const[@value="Chef"]')
  end
  recipe { |ast| recipe_def_mixin(ast) }
  library { |ast| recipe_def_mixin(ast) }
  resource { |ast| recipe_def_mixin(ast) }

end
