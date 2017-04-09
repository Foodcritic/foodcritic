rule "FC074", "LWRP should use DSL to define resource's default action" do
  tags %w{correctness lwrp}
  resource do |ast, filename|
    # See if we're in a custom resource not an LWRP. Only LWRPs need the default_action
    if ["//def/bodystmt/descendant::assign/
      var_field/ivar/@value='@action'"].any? { |expr| ast.xpath(expr) }
      [file_match(filename)]
    end
  end
end
