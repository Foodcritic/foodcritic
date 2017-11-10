rule "FC106", "Use the gid property in user instead of group" do
  tags %w{correctness}
  recipe do |ast|
    find_resources(ast, type: "user").find_all do |user_resource|
      resource_attribute(user_resource, "group")
    end
  end
end
