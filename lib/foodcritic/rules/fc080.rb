rule "FC080", "User resource uses supports property" do
  tags %w{deprecated chef13}
  recipe do |ast|
    matches = []
    find_resources(ast, type: "user").find_all do |cmd|
      matches << cmd.xpath(%q{descendant::fcall[ident/@value='supports']|descendant::command[ident/@value='supports']})
    end
    matches
  end
end
