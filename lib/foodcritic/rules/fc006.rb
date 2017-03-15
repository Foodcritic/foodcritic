rule "FC006", "Mode should be quoted or fully specified when "\
     "setting file permissions" do
  tags %w{correctness files}
  recipe do |ast|
    ast.xpath(%q{//ident[@value='mode']/parent::command/
      descendant::int[string-length(@value) < 5
      and not(starts-with(@value, "0")
      and string-length(@value) = 4)][count(ancestor::aref) = 0]/
      ancestor::method_add_block})
  end
end
