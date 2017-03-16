rule "FC047", "Attribute assignment does not specify precedence" do
  tags %w{attributes correctness chef11}
  recipe do |ast|
    attribute_access(ast).map do |att|
      exclude_att_types = '[count(following-sibling::ident[
        is_att_type(@value) or @value = "run_state"]) = 0]'
      att.xpath(%Q{ancestor::assign[*[self::field | self::aref_field]
        [descendant::*[self::vcall | self::var_ref][ident/@value="node"]
        #{exclude_att_types}]]}, AttFilter.new) +
        att.xpath(%Q{ancestor::binary[@value="<<"]/*[position() = 1]
          [self::aref]
          [descendant::*[self::vcall | self::var_ref]#{exclude_att_types}
          /ident/@value="node"]}, AttFilter.new)
    end
  end
end
