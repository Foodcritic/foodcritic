rule "FC093", "Generated README text needs updating" do
  tags %w{readme supermarket}
  cookbook do |path|
    readme = File.join(path, "README.md")
    generated_readme = "TODO: Enter the cookbook description here."
    if File.exist?(readme) && File.foreach(readme).grep(/#{generated_readme}/).any?
      [file_match(readme)]
    end
  end
end
