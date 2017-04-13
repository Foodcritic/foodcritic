rule "FC071", "Missing LICENSE file" do
  tags %w{style license}
  cookbook do |path|
    unless ::File.exist?("metadata.rb") && field_value(read_ast("metadata.rb"), "license").casecmp("All Rights Reserved") == 0
      ensure_file_exists(path, "LICENSE")
    end
  end
end
