rule "FC099", "Deprecated Chef::Mixin::LanguageIncludeRecipe mixin used" do
  tags %w{chef14 deprecated}
  def lang_include_mixin(ast)
    # include Chef::Mixin::LanguageIncludeRecipe
    ast.xpath('//const_path_ref/const[@value="LanguageIncludeRecipe"]/..//const[@value="Mixin"]/..//const[@value="Chef"]')
  end
  recipe  { |ast| lang_include_mixin(ast) }
  library { |ast| lang_include_mixin(ast) }
  resource { |ast| lang_include_mixin(ast) }

end
