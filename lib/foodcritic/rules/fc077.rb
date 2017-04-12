rule "FC077", 'Metadata uses the deprecated "replaces" keyword' do
  tags %w{metadata deprecated chef13}
  metadata do |ast, filename|
    [file_match(filename)] if field(ast, "replaces").any?
  end
end
