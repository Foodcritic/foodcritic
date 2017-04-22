rule "FC082", "node.set or node.set_unless used to set node attributes" do
  tags %w{chef14 deprecated}
  def node_sets(ast)
    # if someone wants to minimize this xpath query that'd be great
    ast.xpath('//call[(vcall|var_ref)/ident/@value="node"]
    [ident/@value="set"] |
    //call[(vcall|var_ref)/ident/@value="node"]
    [ident/@value="set_unless"]')
  end
  recipe { |ast| node_sets(ast) }
  library { |ast| node_sets(ast) }
end
