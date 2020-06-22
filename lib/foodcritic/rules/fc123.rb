rule "FC123", "Content of a cookbook file is larger than 1MB" do
  tags %w{files}
  cookbook do |path|
    values = []
    files_path = File.join(path, "files")
    if File.exist?(files_path)
      Dir.glob("#{files_path}/**/*").each do |file|
        size = File.size(file)
        if size > 1024 * 1024 # 1 megabyte
          values += [file_match(file)]
        end
      end
    end
    values
  end
end
