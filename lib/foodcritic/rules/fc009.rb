rule "FC009", "Resource attribute not recognised" do
  tags %w{correctness}
  recipe do |ast|
    matches = []
    resource_attributes_by_type(ast).each do |type, resources|
      resources.each do |resource|
        resource.keys.map(&:to_sym).reject do |att|
          resource_attribute?(type.to_sym, att)
        end.each do |invalid_att|
          matches << find_resources(ast, type: type).find do |res|
            resource_attributes(res).include?(invalid_att.to_s)
          end
        end
      end
    end
    matches
  end
end
