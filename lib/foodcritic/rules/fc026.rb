rule "FC026", "Conditional execution block attribute contains only string" do
  tags %w{correctness}
  recipe do |ast|
    find_resources(ast).map { |r| resource_attributes(r) }.map do |resource|
      [resource["not_if"], resource["only_if"]]
    end.flatten.compact.select do |condition|
      condition.respond_to?(:xpath) &&
        !condition.xpath("descendant::string_literal").empty? &&
        !condition.xpath("(stmts_add|bodystmt/stmts_add)/string_literal").empty? && # stmts_add can go away with Ruby 2.4
        condition.xpath('descendant::stmts_add[count(ancestor::
          string_literal) = 0]').size == 1
    end
  end
end
