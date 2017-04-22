rule "FC008", "Generated cookbook metadata needs updating" do
  tags %w{metadata supermarket}
  metadata do |ast, filename|
    [
      { "maintainer" => "YOUR_COMPANY_NAME" },
      { "maintainer" => "The Authors" },
      { "maintainer_email" => "YOUR_EMAIL" },
      { "maintainer_email" => "you@example.com" },
    ].map do |metadata_hash|
      field, value = metadata_hash.to_a.first
      field(ast, field).xpath("descendant::tstring_content[@value='#{value}']")
    end
  end
end
