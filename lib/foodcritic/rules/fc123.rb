rule "FC123", "Content of files/ is larger than 1MB" do
  tags %w{files}
  cookbook do |path|
    values = []
    Dir.foreach(File.join(path, "files")) do |file|
      next if [".", ".."].member?(file)
      size = File.size(File.join(path, "files", file))
      if size > 1024 * 1024 # 1 megabyte
        values += [file_match(File.join(path, "files", file))]
      end
    end
    values
  end
end
