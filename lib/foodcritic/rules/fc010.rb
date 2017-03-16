rule "FC010", "Invalid search syntax" do
  tags %w{correctness search}
  recipe do |ast|
    # This only works for literal search strings
    literal_searches(ast).reject { |search| valid_query?(search["value"]) }
  end
end
