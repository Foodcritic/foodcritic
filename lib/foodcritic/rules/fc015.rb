rule "FC015", "Consider converting definition to a Custom Resource" do
  tags %w{style definitions lwrp}
  cookbook do |dir|
    Dir[File.join(dir, "definitions", "*.rb")].reject do |entry|
      [".", ".."].include? entry
    end.map { |entry| file_match(entry) }
  end
end
