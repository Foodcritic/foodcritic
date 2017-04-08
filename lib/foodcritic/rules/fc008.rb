rule "FC008", "Generated cookbook metadata needs updating" do
  tags %w{metadata supermarket}
  metadata do |ast, filename|
    [
      { "maintainer" => "YOUR_COMPANY_NAME" },
      { "maintainer" => "The Authors" },
      { "maintainer_email" => "YOUR_EMAIL" },
      { "maintainer_email" => "you@example.com" },
    ].map do |metadata_hash|
      ast.xpath(%Q{//command[ident/@value='#{metadata_hash.keys[0]}']/
                   descendant::tstring_content[@value='#{metadata_hash.values[0]}']})
    end
  end
end
