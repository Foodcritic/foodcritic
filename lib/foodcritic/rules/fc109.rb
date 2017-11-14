rule "FC109", "Use platform-specific package resources instead of provider property" do
  tags %w{correctness}
  recipe do |ast|
    find_resources(ast, type: "package").find_all do |package_resources|
      resource_attribute(package_resources, "provider")
    end
  end
end
