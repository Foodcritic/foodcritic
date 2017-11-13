rule "FC075", "Cookbook uses node.save to save partial node data to the chef-server mid-run" do
  tags %w{correctness}
  recipe do |ast|
    ast.xpath('//call[(vcall|var_ref)/ident/@value="node"]
    [ident/@value="save"]')
  end
end
