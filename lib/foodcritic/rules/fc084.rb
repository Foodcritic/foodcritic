rule "FC084", "Deprecated Chef::REST class used" do
  tags %w{chef13 deprecated}
  def rest(ast)
    ast.xpath('//const_path_ref/const[@value="REST"]/..//const[@value="Chef"]/../../..')
  end
  recipe { |ast| rest(ast) }
  library { |ast| rest(ast) }

end
