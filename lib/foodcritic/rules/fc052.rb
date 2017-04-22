rule "FC052", 'Metadata uses the deprecated "suggests" keyword' do
  tags %w{style metadata deprecated}
  metadata do |ast, filename|
    field(ast, 'suggests')
  end
end
