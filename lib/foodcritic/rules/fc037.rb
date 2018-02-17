rule "FC037", "Invalid notification action" do
  tags %w{correctness notifications}
  recipe do |ast|
    find_resources(ast).select do |resource|
      notifications(resource).any? do |n|
        type = case n[:type]
               when :notifies then n[:resource_type]
               when :subscribes then resource_type(resource).to_sym
               end
        # either the action is a string or it's not nil (means it was a variable) and not valid
        n[:action].is_a?(String) || (!n[:action].nil? && !resource_action?(type, n[:action]))
      end
    end
  end
end
