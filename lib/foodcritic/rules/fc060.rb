rule "FC060", "LWRP provider declares use_inline_resources and declares #action_<name> methods" do
  tags %w{correctness lwrp}
  provider do |ast, filename|
    use_inline_resources = !ast.xpath('//*[self::vcall or self::var_ref]/ident
      [@value="use_inline_resources"]').empty?
    if use_inline_resources
      ast.xpath(%q{//def[ident[contains(@value, 'action_')]]})
    end
  end
end
