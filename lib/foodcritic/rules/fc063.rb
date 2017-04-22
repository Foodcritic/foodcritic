rule "FC063", "Cookbook incorrectly depends on itself" do
  tags %w{metadata correctness}
  metadata do |ast, filename|
    name = cookbook_name(filename)
    field(ast, 'depends').xpath("descendant::tstring_content[@value='#{name}']")
  end
end
