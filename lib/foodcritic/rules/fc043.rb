rule "FC043", "Prefer new notification syntax" do
  tags %w{style notifications deprecated}
  recipe do |ast|
    find_resources(ast).select do |resource|
      notifications(resource).any? { |notify| notify[:style] == :old }
    end
  end
end
