require 'fileutils'

module FoodCritic
  # Output to a file in checkstyle's xml format
  #
  # Useful with many CI environments that have support already for java checkstyle
  class CheckstyleOutput
    attr_writer :destination

    # Output the checkstyle formatted xml
    # number.
    #
    # @param [Review] review The review to output.
    def output(review)
      @destination ||= 'checkstyle-report.xml'

      FileUtils.mkdir_p(File.dirname(@destination))
      File.open(@destination, 'w') do |outfile|
        outfile.write "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<checkstyle version=\"5.0\">\n"
        review.warnings_by_file_and_line.each do |file, line|
          outfile.write "  <file name=\"#{file}\">\n"
          line.each do |line, violations|
            violations.each do |rule|
              severity = rule.tags.include?('correctness') ? 'error' : 'warning'
              source = rule.source.source_location.join(':') + ':RULE.' + rule.code
              outfile.write "    <error line=\"#{line}\" severity=\"#{severity}\" message=\"#{rule.code}: #{rule.name}\" source=\"#{source}\"/>\n"
            end
          end
          outfile.write "  </file>\n"
        end
        outfile.write '</checkstyle>'
      end
    end

  end
end
