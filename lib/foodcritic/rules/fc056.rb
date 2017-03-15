rule "FC056", "Ensure maintainer_email is set in metadata" do
  tags %w{correctness metadata supermarket}
  metadata do |ast, filename|
    [file_match(filename)] unless field(ast, "maintainer_email").any?
  end
end
