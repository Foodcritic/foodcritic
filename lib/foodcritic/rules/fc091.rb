rule "FC091", "Use property not attribute in custom resources" do
  tags %w{correctness}

  resource do |ast|
    # Make sure we're in a custom resource not an LWRP
    if ast.xpath("//command/ident/@value='action'")
      ast.xpath("//command[ident/@value='attribute']")
    end
  end
end
