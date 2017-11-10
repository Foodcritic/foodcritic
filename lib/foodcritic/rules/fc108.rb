rule "FC108", "Resource should not define a property named 'name'" do
  tags %w{correctness}
  resource do |ast|
    # Make sure we're in a custom resource not an LWRP
    if ast.xpath("//command/ident/@value='action'")
      # command has a child of type ident with a value of "property". That tells us
      # we're in a property. Quite a ways desecendant from that is another ident
      # with value of "name"
      ast.xpath("//command[ident/@value='property' and descendant::symbol_literal/symbol/ident/@value='name']")
    end
  end
end
