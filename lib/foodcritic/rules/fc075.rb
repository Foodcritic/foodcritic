rule "FC075", "Cookbook uses node.save to save partial node data to the chef-server mid-run" do
  tags %w{correctness}
  def node_saves(ast)
    ast.xpath('//call[(vcall|var_ref)/ident/@value="node"]
    [ident/@value="save"]')
  end
  recipe { |ast| node_saves(ast) }
  library { |ast| node_saves(ast) }
end
