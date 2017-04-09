rule "FC045", "Metadata does not contain cookbook name" do
  tags %w{correctness metadata chef12}
  metadata do |ast, filename|
    [file_match(filename)] unless field(ast, "name").any?
  end
end
