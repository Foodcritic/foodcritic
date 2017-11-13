rule "FC096", "Cookbook uses deprecated libvirt virtualization ohai data" do
  tags %w{deprecated chef14}
  recipe do |ast|
    ast.xpath('//aref[aref/vcall/ident/@value="node"]
      [aref/args_add_block/args_add/string_literal/string_add/tstring_content/@value="virtualization" and
      args_add_block/args_add/string_literal/string_add/tstring_content/@value="uri"]')
  end
end
