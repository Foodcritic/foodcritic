rule "FC076", 'Metadata uses the deprecated "conflicts" keyword' do
  tags %w{metadata deprecated chef13}
  metadata do |ast, filename|
    [file_match(filename)] if field(ast, "conflicts").any?
  end
end
