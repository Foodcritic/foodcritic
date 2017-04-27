rule "FC087", "Library maps provider with deprecated Chef::Platform.set" do
  tags %w{chef13 deprecated}

  library do |ast|
    ast.xpath('//const_path_ref/const[@value="Platform"]/..//const[@value="Chef"]/../../../ident[@value="set"]')
  end
end
