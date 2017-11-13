rule "FC086", "Use databag helper methods to load data bag items" do
  tags %w{style}
  recipe do |ast|
    ast.xpath('//const_path_ref/const[@value="EncryptedDataBagItem" or @value="DataBagItem"]/..//const[@value="Chef"]/../../..//ident[@value="load"]/..')
  end
end
