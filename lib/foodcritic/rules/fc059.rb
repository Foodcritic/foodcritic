rule "FC059", "LWRP provider does not declare use_inline_resources" do
  tags %w{correctness}
  provider do |ast, filename|
    use_inline_resources = !ast.xpath('//*[self::vcall or self::var_ref]/ident
      [@value="use_inline_resources"]').empty?
    unless use_inline_resources
      [file_match(filename)]
    end
  end
end
