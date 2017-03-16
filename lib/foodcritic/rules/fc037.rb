rule "FC037", "Invalid notification action" do
  tags %w{correctness}
  recipe do |ast|
    find_resources(ast).select do |resource|
      notifications(resource).any? do |n|
        type = case n[:type]
               when :notifies then n[:resource_type]
               when :subscribes then resource_type(resource).to_sym
               end
        n[:action].size > 0 && !resource_action?(type, n[:action])
      end
    end
  end
end
