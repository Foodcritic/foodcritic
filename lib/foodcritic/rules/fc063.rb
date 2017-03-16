rule "FC063", "Cookbook incorrectly depends on itself" do
  tags %w{metadata correctness}
  metadata do |ast, filename|
    name = cookbook_name(filename)
    ast.xpath(%Q{//command[ident/@value='depends']/
              descendant::tstring_content[@value='#{name}']})
  end
end
