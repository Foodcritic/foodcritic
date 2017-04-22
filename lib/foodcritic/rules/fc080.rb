rule "FC080", "User resource uses supports property" do
  tags %w{deprecated chef13}
  recipe do |ast|
    find_resources(ast, type: "user").xpath(%q{descendant::fcall[ident/@value='supports']|descendant::command[ident/@value='supports']})
  end
end
