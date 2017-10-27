rule "FC095", "Cookbook uses deprecated cloud_v2 ohai plugin data" do
  tags %w{deprecated chef14}

  recipe do |ast|
    ast.xpath('//aref[vcall/ident/@value="node"]
      /args_add_block/args_add/string_literal/string_add/tstring_content[@value="cloud_v2"]')
  end
end
