rule "FC021", "Resource condition in provider may not behave as expected" do
  tags %w{correctness lwrp}
  provider do |ast|
    find_resources(ast).map do |resource|
      condition = resource.xpath(%q{//method_add_block/
        descendant::ident[@value='not_if' or @value='only_if']/
        ancestor::*[self::method_add_block or self::command][1][descendant::
        ident/@value='new_resource']/ancestor::stmts_add[2]/method_add_block/
        command[count(descendant::string_embexpr) = 0]})
      condition
    end.compact
  end
end
