rule "FC018", "LWRP uses deprecated notification syntax" do
  tags %w{correctness lwrp deprecated chef13}
  provider do |ast|
    ast.xpath("//assign/var_field/ivar[@value='@updated']").map do |class_var|
      match(class_var)
    end + ast.xpath(%q{//assign/field/*[self::vcall or self::var_ref/ident/
                       @value='new_resource']/../ident[@value='updated']})
  end
end
