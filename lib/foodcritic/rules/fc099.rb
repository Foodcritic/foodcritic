rule "FC099", "Deprecated Chef::Mixin::LanguageIncludeRecipe mixin used" do
  tags %w{chef14 deprecated}
  recipe do |ast|
    # include Chef::Mixin::LanguageIncludeRecipe
    ast.xpath('//const_path_ref/const[@value="LanguageIncludeRecipe"]/..//const[@value="Mixin"]/..//const[@value="Chef"]')
  end
end
