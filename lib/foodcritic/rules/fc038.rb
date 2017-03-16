rule "FC038", "Invalid resource action" do
  tags %w{correctness}
  recipe do |ast|
    find_resources(ast).select do |resource|
      actions = resource_attributes(resource)["action"]
      if actions.respond_to?(:xpath)
        actions = actions.xpath('descendant::array/
          descendant::symbol/ident/@value')
      else
        actions = Array(actions)
      end
      actions.reject { |a| a.to_s.empty? }.any? do |action|
        !resource_action?(resource_type(resource), action)
      end
    end
  end
end
