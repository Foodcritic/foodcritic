module FoodCritic
  module REPL

    # Convenience method to repeat the last check. Intended to be used from the
    # REPL.
    def recheck
      check(@last_cookbook_paths, @last_options)
    end

    def reset_rules
      load_rules!(@last_options)
    end

    # Convenience method to retrieve the last review. Intended to be used from
    # the REPL.
    def review
      @review
    end

    def with_repl(cookbook_paths, options)
      @last_cookbook_paths, @last_options = cookbook_paths, options
      @review = yield if block_given?
      binding.pry if options[:repl]
      @review
    end

  end
end
