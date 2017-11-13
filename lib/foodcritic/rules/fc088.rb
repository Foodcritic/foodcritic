rule "FC088", "Prefer Mixlib::Shellout over deprecated Chef::Mixin::Command" do
  tags %w{chef13 deprecated}
  recipe do |ast|
    ast.xpath('//const_path_ref/const[@value="Command"]/..//const[@value="Mixin"]/..//const[@value="Chef"]')
  end
end
