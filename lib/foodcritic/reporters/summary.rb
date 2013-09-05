require 'fileutils'
require 'set'

module FoodCritic

  # Default output showing a summary view.
  class SummaryOutput
    attr_writer :destination
    # Output a summary view only listing the matching rules, file and line
    # number.
    #
    # @param [Review] review The review to output.
    def output(review)
      if @destination then
        FileUtils.mkdir_p(File.dirname(@destination))
        File.open(@destination, 'w') { |outfile| outfile.puts(review.to_s) }
      else
        puts review.to_s
      end
    end
  end
end
