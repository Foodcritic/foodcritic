rule "FC057", "Library provider does not declare use_inline_resources" do
  tags %w{correctness}
  library do |ast, filename|
    ast.xpath('//const_path_ref/const[@value="LWRPBase"]/..//const[@value="Provider"]/../../..').select do |x|
      x.xpath('//*[self::vcall or self::var_ref]/ident[@value="use_inline_resources"]').empty?
    end
  end
end
