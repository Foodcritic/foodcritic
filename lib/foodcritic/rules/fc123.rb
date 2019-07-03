rule "FC123", "Content of a cookbook file is larger than 1MB" do
  tags %w{files}
  cookbook do |path|
    values = []
    files_path = File.join(path, "files")
    if File.exist?(files_path)
      Dir.foreach(files_path) do |file|
        next if ['.', '..'].member?(file)
        size = File.size(File.join(files_path,file))
        if size > 1024*1024 # 1 megabyte
          values += [file_match(File.join(files_path,file))]
        end
      end
    end
    values
  end
end
