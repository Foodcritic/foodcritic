rule "FC008", "Generated cookbook metadata needs updating" do
  tags %w{style metadata}
  metadata do |ast, filename|
    {
      "maintainer" => "YOUR_COMPANY_NAME",
      "maintainer_email" => "YOUR_EMAIL",
    }.map do |field, value|
      ast.xpath(%Q{//command[ident/@value='#{field}']/
                   descendant::tstring_content[@value='#{value}']})
    end
  end
end
