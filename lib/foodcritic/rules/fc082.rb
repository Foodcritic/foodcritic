rule "FC082", "Deprecated node.set or node.set_unless used to set node attributes" do
  tags %w{chef14 deprecated}
  recipe do |ast|
    ast.xpath('//call[(vcall|var_ref)/ident/@value="node"]
    [ident[@value="set" or @value="set_unless"]]')
  end
end
