rule "FC067", "Ensure at least one platform supported in metadata" do
  tags %w{metadata supermarket}
  metadata do |ast, filename|
    [file_match(filename)] unless field(ast, "supports").any?
  end
end
