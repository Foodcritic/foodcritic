rule "FC089", "Prefer Mixlib::Shellout over deprecated Chef::ShellOut" do
  tags %w{chef13 deprecated}
  recipe do |ast|
    ast.xpath('//const_path_ref[var_ref/const[@value="Chef"]]/const[@value="ShellOut"]')
  end
end
