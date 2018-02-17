rule "FC115", "Custom resource contains a name_property that is required" do
  tags %w{correctness}
  recipe do |ast|
    ast.xpath("//command[ident/@value='property'
      and descendant::bare_assoc_hash/assoc_new[label/@value='name_property:' and kw/@value='true']
      and descendant::bare_assoc_hash/assoc_new[label/@value='required:' and kw/@value='true']
      and descendant::symbol_literal/symbol/ident/@value!='name']")
  end
end
