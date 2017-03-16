rule "FC031", "Cookbook without metadata file" do
  tags %w{correctness metadata}
  cookbook do |filename|
    if !File.exist?(File.join(filename, "metadata.rb"))
      [file_match(File.join(filename, "metadata.rb"))]
    end
  end
end
