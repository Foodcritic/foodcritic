rule "FC027", "Resource sets internal attribute" do
  tags %w{correctness}
  recipe do |ast|
    find_resources(ast, type: :service).map do |service|
      service unless (resource_attributes(service).keys &
                        %w{enabled running}).empty?
    end.compact
  end
end
