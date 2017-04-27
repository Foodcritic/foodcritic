rule "FC083", "Execute resource using deprecated 'path' property" do
  tags %w{deprecated chef12}
  recipe do |ast|
    find_resources(ast, type: "execute").xpath('(.//command|.//fcall)[ident/@value="path"]')
  end
end
