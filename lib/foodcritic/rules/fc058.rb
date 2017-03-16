rule "FC058", "Library provider declares use_inline_resources and declares #action_<name> methods" do
  tags %w{correctness}
  library do |ast, filename|
    ast.xpath('//const_path_ref/const[@value="LWRPBase"]/..//const[@value="Provider"]/../../..').select do |x|
      x.xpath('//*[self::vcall or self::var_ref]/ident[@value="use_inline_resources"]').length > 0 &&
        x.xpath(%q{//def[ident[contains(@value, 'action_')]]}).length > 0
    end
  end
end
