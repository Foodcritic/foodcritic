rule "FC102", "Deprecated Chef::DSL::Recipe::FullDSL class used" do
  tags %w{chef14 deprecated}
  recipe do |ast|
    # include Chef::DSL::Recipe::FullDSL
    ast.xpath('//const_path_ref/const[@value="FullDSL"]/..//const[@value="Recipe"]/..//const[@value="DSL"]/..//const[@value="Chef"]')
  end
end
