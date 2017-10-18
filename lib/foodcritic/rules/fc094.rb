rule "FC094", "Cookbook uses deprecated filesystem2 ohai plugin data" do
  tags %w{deprecated chef15}

  recipe do |ast|
    ast.xpath('//aref[vcall/ident/@value="node"]
      /args_add_block/args_add/string_literal/string_add/tstring_content[@value="filesystem2"]')
  end
end
