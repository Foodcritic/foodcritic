rule "FC116", "Cookbook depends on the deprecated compat_resource cookbook" do
  tags %w{deprecated}
  metadata do |ast, filename|
    [file_match(filename)] if declared_dependencies(ast).include?("compat_resource")
  end
end
