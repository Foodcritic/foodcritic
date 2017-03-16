rule "FC064", "Ensure issues_url is set in metadata" do
  tags %w{metadata supermarket chef12}
  metadata do |ast, filename|
    [file_match(filename)] unless field(ast, "issues_url").any?
  end
end
