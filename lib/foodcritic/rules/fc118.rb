rule "FC118", "Resource property setting name_attribute vs. name_property" do
  tags %w{correctness}
  recipe do |ast|
    ast.xpath("//command[ident/@value='property'
      and descendant::bare_assoc_hash/assoc_new/label/@value='name_attribute:']")
  end
end
