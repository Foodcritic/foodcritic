rule "FC100", "Deprecated Chef::Mixin::Language mixin used" do
  tags %w{chef14 deprecated}
  recipe do |ast|
    # include Chef::Mixin::Language
    ast.xpath('//const_path_ref/const[@value="Language"]/..//const[@value="Mixin"]/..//const[@value="Chef"]')
  end
end
