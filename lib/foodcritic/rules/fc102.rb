rule "FC102", "Deprecated Chef::DSL::Recipe::FullDSL class used" do
  tags %w{chef14 deprecated}
  def full_dsl(ast)
    # include Chef::DSL::Recipe::FullDSL
    ast.xpath('//const_path_ref/const[@value="FullDSL"]/..//const[@value="Recipe"]/..//const[@value="DSL"]/..//const[@value="Chef"]')
  end
  recipe  { |ast| full_dsl(ast) }
  library { |ast| full_dsl(ast) }
  resource { |ast| full_dsl(ast) }

end
