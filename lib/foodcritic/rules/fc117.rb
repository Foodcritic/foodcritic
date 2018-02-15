rule "FC117", "Do not use kind_of in custom resource properties" do
  tags %w{correctness}
  resource do |ast|
    # Make sure we're in a custom resource not an LWRP
    if ast.xpath("//command/ident/@value='action'")
      ast.xpath("//command[ident/@value='property'][args_add_block//label/@value='kind_of:']")
    end
  end
end
