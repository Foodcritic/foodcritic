rule "FC120", "Do not set the name property directly on a resource" do
  tags %w{correctness}
  recipe do |ast|
    find_resources(ast).xpath('(.//command|.//fcall)[ident/@value="name"]')
  end
end
