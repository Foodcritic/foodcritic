rule "FC050", "Name includes invalid characters" do
  tags %w{correctness environments roles}
  def invalid_name(ast)
    field(ast, :name) unless field_value(ast, :name) =~ /^[a-zA-Z0-9_\-]+$/
  end
  environment { |ast| invalid_name(ast) }
  role { |ast| invalid_name(ast) }
end
