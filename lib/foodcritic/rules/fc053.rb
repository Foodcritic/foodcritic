rule "FC053", 'Metadata uses the deprecated "recommends" keyword' do
  tags %w{style metadata deprecated}
  metadata do |ast, filename|
    ast.xpath(%q{//command[ident/@value='recommends']})
  end
end
