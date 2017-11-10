rule "FC107", "Resource uses epic_fail instead of ignore_failure" do
  tags %w{deprecated chef14}
  recipe do |ast|
    find_resources(ast).xpath('(.//command|.//fcall)[ident/@value="epic_fail"]')
  end
end
