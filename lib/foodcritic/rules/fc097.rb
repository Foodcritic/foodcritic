rule "FC097", "Deprecated Chef::Mixin::LanguageIncludeAttribute mixin used" do
  tags %w{chef14 deprecated}
  def lang_include_attrib_mixin(ast)
    # include Chef::Mixin::LanguageIncludeAttribute
    ast.xpath('//const_path_ref/const[@value="LanguageIncludeAttribute"]/..//const[@value="Mixin"]/..//const[@value="Chef"]')
  end
  recipe { |ast| lang_include_attrib_mixin(ast) }
  library { |ast| lang_include_attrib_mixin(ast) }
  resource { |ast| lang_include_attrib_mixin(ast) }

end
