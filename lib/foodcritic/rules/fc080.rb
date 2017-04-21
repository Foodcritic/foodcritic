rule "FC080", "User resource uses supports property" do
  tags %w{deprecated chef13}
  recipe do |ast|
    find_resources(ast, type: "user").find_all do |cmd|
      cmd.xpath(%q{//fcall[ident/@value='supports']})
    end
  end
end
