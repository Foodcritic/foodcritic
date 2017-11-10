rule "FC104", "Use the :run action in ruby_block instead of :create" do
  tags %w{correctness}
  recipe do |ast|
    find_resources(ast, type: "ruby_block").find_all do |ruby_resource|
      resource_attribute(ruby_resource, "action") == :create
    end
  end
end
