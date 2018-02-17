rule "FC119", "windows_task :change action no longer exists in Chef 13" do
  tags %w{deprecation chef13}
  recipe do |ast|
    matches = []
    find_resources(ast).each do |resource|
      # if it's a ruby_block check for the :create action
      matches << resource if resource_attribute(resource, "action") == :change && resource_type(resource) == "windows_task"

      # no matter what check notification
      notifications(resource).any? do |notification|
        matches << resource if notification[:resource_type] == :windows_task && notification[:action] == :change
      end
    end
    matches
  end
end
