module FoodCritic
  # Expose if any errors are found in parsing
  class ErrorChecker < Ripper::SexpBuilder
    # Create a new instance of ErrorChecker
    #
    # @see Ripper::SexpBuilder#initialize
    def initialize(*args)
      super(*args)
      @found_error = false
    end

    # Was an error encountered during parsing?
    def error?
      @found_error
    end

    # Register with all available error handlers.
    def self.register_error_handlers
      error_methods = SexpBuilder.public_instance_methods.grep(/^on_.*_error$/)
      error_methods.sort.each do |err_meth|
        define_method(err_meth) { |*| @found_error = true }
      end
    end

    self.register_error_handlers
  end
end
