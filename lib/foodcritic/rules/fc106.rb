rule "FC106", "Use the plist_hash property in launchd instead of hash" do
  tags %w{deprecated chef13}
  recipe do |ast|
    find_resources(ast, type: "launchd").find_all do |launchd_resource|
      resource_attribute(launchd_resource, "hash")
    end
  end
end
