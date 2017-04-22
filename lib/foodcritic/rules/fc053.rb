rule "FC053", 'Metadata uses the deprecated "recommends" keyword' do
  tags %w{style metadata deprecated}
  metadata do |ast, filename|
    field(ast, "recommends")
  end
end
