rule "FC002", "Avoid string interpolation where not required" do
  tags %w{style strings}
  recipe do |ast|
    ast.xpath(%q{//*[self::string_literal | self::assoc_new]/string_add[
      count(descendant::string_embexpr) = 1 and
      count(string_add) = 0]})
  end
end
