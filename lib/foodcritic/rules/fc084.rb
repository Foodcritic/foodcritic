rule "FC084", "Deprecated Chef::REST class used" do
  tags %w{chef13 deprecated}
  recipe do |ast|
    ast.xpath('//const_path_ref/const[@value="REST"]/..//const[@value="Chef"]/../../..')
  end
end
