rule "FC028", "Incorrect #platform? usage" do
  tags %w{correctness}
  recipe do |ast|
    ast.xpath(%q{//*[self::call | self::command_call]
      [(var_ref|vcall)/ident/@value='node']
      [ident/@value="platform?"]})
  end
end
