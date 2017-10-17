rule "FC100", "Deprecated Chef::Mixin::Language class used" do
  tags %w{chef14 deprecated}
  def lang_mixin(ast)
    # include Chef::Mixin::Language
    ast.xpath('//const_path_ref/const[@value="Language"]/..//const[@value="Mixin"]/..//const[@value="Chef"]')
  end
  recipe  { |ast| lang_mixin(ast) }
  library { |ast| lang_mixin(ast) }
  resource { |ast| lang_mixin(ast) }

end
