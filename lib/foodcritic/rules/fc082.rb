rule "FC082", "node.set used to set node attributes" do
  tags %w{chef14 deprecated}
  def node_sets(ast)
    ast.xpath('//call[(vcall|var_ref)/ident/@value="node"]
    [ident/@value="set"]')
  end
  recipe { |ast| node_sets(ast) }
  library { |ast| node_sets(ast) }
end
