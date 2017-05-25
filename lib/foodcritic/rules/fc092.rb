rule "FC092", "Custom resources should not define actions" do
  tags %w{correctness}

  resource do |ast|
    # Make sure we're in a custom resource not an LWRP
    if ast.xpath("//command/ident/@value='action'")
      ast.xpath("//command[ident/@value='actions']")
    end

  end
end
