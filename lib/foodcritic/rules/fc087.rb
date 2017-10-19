rule "FC087", "Library uses deprecated Chef::Platform methods" do
  tags %w{chef13 deprecated}

  library do |ast|
    ast.xpath('//const_path_ref/const[@value="Platform"]/..//const[@value="Chef"]/../../../ident[@value="set" or @value="provider_for_resource" or @value="find_provider"]')
  end
end
