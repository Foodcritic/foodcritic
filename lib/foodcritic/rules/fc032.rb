rule "FC032", "Invalid notification timing" do
  tags %w{correctness notifications}
  recipe do |ast|
    valid_timings = if resource_attribute?("file", "notifies_before")
                      %i{delayed immediate before}
                    else
                      %i{delayed immediate}
                    end
    find_resources(ast).select do |resource|
      notifications(resource).any? do |notification|
        ! valid_timings.include? notification[:timing]
      end
    end
  end
end
