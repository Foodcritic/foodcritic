rule "FC048", "Prefer shell_out helper method to shelling out with Ruby" do
  tags %w{portability}
  recipe do |ast|
    xstring_literal = ast.xpath("//xstring_literal")
    next xstring_literal if xstring_literal.any?

    ast.xpath('//*[self::command or self::fcall]/ident[@value="system"]').select do |x|
      resource_name = x.xpath("ancestor::do_block/preceding-sibling::command/ident/@value")
      next false if resource_name.any? && resource_name.all? { |r| resource_attribute?(r.to_s, "system") }

      next x.xpath('count(following-sibling::args_add_block/descendant::kw[@value="true" or @value="false"]) = 0')
    end
  end
end
