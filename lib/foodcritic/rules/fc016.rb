rule "FC016", "LWRP does not declare a default action" do
  tags %w{correctness lwrp}
  resource do |ast, filename|
    unless ["//ident/@value='default_action'",
     "//def/bodystmt/descendant::assign/
      var_field/ivar/@value='@action'"].any? { |expr| ast.xpath(expr) }
      [file_match(filename)]
    end
  end
end
