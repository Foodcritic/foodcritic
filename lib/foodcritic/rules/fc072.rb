rule "FC072", 'metadata should not contain "attribute" keyword' do
  tags %w{metadata style}
  metadata do |ast, filename|
    [file_match(filename)] if field(ast, "attribute").any?
  end
end
