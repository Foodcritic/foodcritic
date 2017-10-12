rule "FC090", "Resource should not ignore failures" do
  tags %w{correctness resource}
  recipe do |ast|
    find_resources(ast).select { |resource| resource_attributes(resource)['ignore_failure'] }.compact
  end
end
