rule "FC031", "Cookbook without metadata.rb file" do
  tags %w{correctness metadata}
  cookbook do |filename|
    unless File.exist?(File.join(filename, "metadata.rb"))
      [file_match(File.join(filename, "metadata.rb"))]
    end
  end
end
