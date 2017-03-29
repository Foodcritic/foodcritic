rule "FC016", "LWRP does not declare a default action" do
  tags %w{correctness lwrp}
  resource do |ast, filename|
    # See if we're in a custom resource not an LWRP. Only LWRPs need the default_action
    next if ast.xpath("//ident/@value='property'")
    unless ["//ident/@value='default_action'",
     "//def/bodystmt/descendant::assign/
      var_field/ivar/@value='@action'"].any? { |expr| ast.xpath(expr) }
      [file_match(filename)]
    end
  end
end
