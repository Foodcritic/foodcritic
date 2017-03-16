rule "FC045", "Metadata does not contain cookbook name" do
  tags %w{correctness metadata chef12}
  metadata do |ast, filename|
    unless ast.xpath('descendant::stmts_add/command/ident/@value="name"')
      [file_match(filename)]
    end
  end
  cookbook do |filename|
    if !File.exist?(File.join(filename, "metadata.rb"))
      [file_match(File.join(filename, "metadata.rb"))]
    end
  end
end
