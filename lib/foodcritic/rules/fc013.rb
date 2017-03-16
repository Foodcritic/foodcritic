rule "FC013", "Use file_cache_path rather than hard-coding tmp paths" do
  tags %w{style files}
  recipe do |ast|
    find_resources(ast, type: "remote_file").find_all do |download|
      path = (resource_attribute(download, "path") ||
        resource_name(download)).to_s
      path.start_with?("/tmp/")
    end
  end
end
