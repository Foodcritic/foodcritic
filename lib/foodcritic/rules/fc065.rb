rule "FC065", "Ensure source_url is set in metadata" do
  tags %w{metadata supermarket chef12}
  metadata do |ast, filename|
    [file_match(filename)] unless field(ast, "source_url").any?
  end
end
