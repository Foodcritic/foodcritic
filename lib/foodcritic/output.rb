module FoodCritic

  # Default output showing a summary view.
  class SummaryOutput
    # Output a summary view only listing the matching rules, file and line number.
    #
    # @param [Review] review The review to output.
    def output(review)
      puts review.to_s
    end
  end

end