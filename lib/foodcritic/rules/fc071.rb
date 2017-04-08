rule "FC071", "Missing LICENSE" do
  tags %w{style license}
  cookbook do |path|
    ensure_file_exists(path, "LICENSE")
  end
end
