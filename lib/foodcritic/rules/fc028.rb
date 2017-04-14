rule "FC028", "Incorrect #platform? or #platform_family? usage" do
  tags %w{correctness}
  recipe do |ast|
    ast.xpath(%q{//*[self::call | self::command_call]
      [(var_ref|vcall)/ident/@value='node']
      [ident/@value="platform?" or ident/@value="platform_family?"]})
  end
end
