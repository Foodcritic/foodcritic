rule "FC086", "Use databag helper methods to load data bag items" do
  tags %w{style}
  def old_dbag(ast)
    ast.xpath('//const_path_ref/const[@value="EncryptedDataBagItem" or @value="DataBagItem"]/..//const[@value="Chef"]/../../..')
  end

  resource { |ast| old_dbag(ast) }
  recipe { |ast| old_dbag(ast) }
  library { |ast| old_dbag(ast) }
end
