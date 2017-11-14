rule "FC109", "Package resources should not specify the provider" do
  tags %w{correctness}
  recipe do |ast|
    find_resources(ast, type: "package").find_all do |package_resources|
      resource_attribute(package_resources, "provider")
    end
  end
end
