rule "FC083", "Execute resource using 'path' property" do
  tags %w{deprecated chef12}
  recipe do |ast|
    matches = []
    find_resources(ast, type: "execute").find_all do |cmd|
      matches << cmd.xpath(%q{descendant::fcall[ident/@value='path']|descendant::command[ident/@value='path']})
    end
    matches
  end
end
