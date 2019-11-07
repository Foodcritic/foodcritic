rule "FC039", "Node method cannot be accessed with key" do
  tags %w{correctness}
  recipe do |ast|
    [{ type: :string, path: "@value" },
     { type: :symbol, path: "ident/@value" }].map do |access_type|
       attribute_access(ast, type: access_type[:type]).select do |att|
         att_name = att.xpath(access_type[:path]).to_s.to_sym
         att_name != :tags && chef_node_methods.include?(att_name)
       end.select do |att|
         !att.xpath('ancestor::args_add_block[position() = 1]
           [preceding-sibling::vcall | preceding-sibling::var_ref]').empty?
       end.select do |att|
         att_type = att.xpath('ancestor::args_add_block[position() = 1]
           /../var_ref/ident/@value').to_s
         ast.xpath("//assign/var_field/ident[@value='#{att_type}']").empty?
       end
     end.flatten
  end
end
