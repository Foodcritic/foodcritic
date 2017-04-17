rule "FC079", "Deprecated easy_install_package resource usage" do
  tags %w{deprecated chef13}
  recipe do |ast|
    find_resources(ast, type: "easy_install_package")
  end
end
