Dir.glob(File.dirname(__FILE__) + '/reporters/*.rb') { |file| require_relative file}

module FoodCritic
  # Reporting manager class
  class Report
    attr_accessor :options

    # Create a new instance
    #
    # @param [Hash] options The configuration options
    def initialize(options)
      @options = options
    end

    # Perform the reporting
    #
    # @param [Review] review The review objects with the results to report on 
    def report(review)
      if review.is_a? Review then
        printer = load_printer(@options)
        printer.destination = @options[:report_dest]
        printer.output(review)
      else
        puts review.to_s
      end
    end

    private
    
    # Load the printer
    def load_printer(options)
      if options.has_key?(:require) then
        begin
          require options[:require]
        rescue
          raise "unable to require #{options[:require]}"
          fail
        end
      end
      if options[:reporter] then
        begin
          printer = options[:reporter].split('::').map do |word|
            @last = @last ? @last : Object
            @last = @last.const_get(word)
          end.last.new
        rescue
          raise "Unable to create instance of reporter #{options[:reporter]}"
        end
        if ! (printer.respond_to?(:output) && printer.respond_to?(:destination=)) then
          raise "#{options[:reporter]} is not a reporter!"
        end
      elsif options.has_key?(:context) && @options[:context] then
        printer = ContextOutput.new
      else
        printer = SummaryOutput.new
      end
      printer
    end

  end
end
