rule "FC097", "Deprecated Chef::Mixin::LanguageIncludeAttribute mixin used" do
  tags %w{chef14 deprecated}
  recipe do |ast|
    # include Chef::Mixin::LanguageIncludeAttribute
    ast.xpath('//const_path_ref/const[@value="LanguageIncludeAttribute"]/..//const[@value="Mixin"]/..//const[@value="Chef"]')
  end
end
