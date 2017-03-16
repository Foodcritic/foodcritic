rule "FC030", "Cookbook contains debugger breakpoints" do
  tags %w{annoyances}
  def pry_bindings(ast)
    ast.xpath('//call[(vcall|var_ref)/ident/@value="binding"]
      [ident/@value="pry"]')
  end
  recipe { |ast| pry_bindings(ast) }
  library { |ast| pry_bindings(ast) }
  metadata { |ast| pry_bindings(ast) }
  template { |ast| pry_bindings(ast) }
end
