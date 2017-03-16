rule "FC012", "Use Markdown for README rather than RDoc" do
  tags %w{supermarket readme}
  cookbook do |filename|
    if File.exist?(File.join(filename, "README.rdoc"))
      [file_match(File.join(filename, "README.rdoc"))]
    end
  end
end
