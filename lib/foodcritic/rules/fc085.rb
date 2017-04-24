rule "FC085", "Resource using new_resource.updated_by_last_action to converge resource" do
  tags %w{chef13 deprecated}
  def updated_by(ast)
    ast.xpath('//call[(vcall|var_ref)/ident/@value="new_resource"]
      [ident/@value="updated_by_last_action"]')
  end

  resource { |ast| updated_by(ast) }
  provider { |ast| updated_by(ast) }
  library { |ast| updated_by(ast) }

end
