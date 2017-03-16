rule "FC055", "Ensure maintainer is set in metadata" do
  tags %w{correctness metadata}
  metadata do |ast, filename|
    [file_match(filename)] unless field(ast, "maintainer").any?
  end
end
