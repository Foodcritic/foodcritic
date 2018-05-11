rule "FC071", "Missing LICENSE file" do
  tags %w{style license opensource}
  cookbook do |path|
    unless ::File.exist?(::File.join(path, "metadata.rb")) && field_value(read_ast(::File.join(path, "metadata.rb")), "license").to_s.casecmp("All Rights Reserved") == 0
      ensure_file_exists(path, "LICENSE")
    end
  end
end
