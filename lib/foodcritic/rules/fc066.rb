rule "FC066", "Ensure chef_version is set in metadata" do
  tags %w{metadata}
  metadata do |ast, filename|
    [file_match(filename)] unless field(ast, "chef_version").any?
  end
end
