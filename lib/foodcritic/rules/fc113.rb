rule "FC113", "Resource declares deprecated use_inline_resources" do
  tags %w{deprecation chef15 lwrp}
  library do |ast|
    matches = []
    ast.xpath('//const_path_ref/const[@value="LWRPBase"]/..//const[@value="Provider"]/../../..').select do |x|
      matches << x.xpath('//*[self::vcall or self::var_ref]/ident[@value="use_inline_resources"]')
    end
    matches
  end
  provider do |ast|
    ast.xpath('//*[self::vcall or self::var_ref]/ident[@value="use_inline_resources"]')
  end
end
