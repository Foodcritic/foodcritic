rule "FC104", "Use the :run action in ruby_block instead of :create" do
  tags %w{correctness}
  recipe do |ast|
    matches = []
    find_resources(ast).each do |resource|
      # if it's a ruby_block check for the :create action
      if ast.xpath('//method_add_block[command/ident[@value="ruby_block"]]')
        matches << resource if resource_attribute(resource, "action") == :create
      end

      # no matter what check notification
      notifications(resource).any? do |notification|
        matches << resource if notification[:resource_type] == :ruby_block && notification[:action] == :create
      end
    end
    matches
  end
end
