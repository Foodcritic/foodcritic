rule "FC103", "Deprecated :uninstall action in chocolatey_package used" do
  tags %w{deprecated chef14}
  recipe do |ast|
    find_resources(ast, type: "chocolatey_package").find_all do |choco_resource|
      resource_attribute(choco_resource, "action") == :uninstall
    end
  end
end
