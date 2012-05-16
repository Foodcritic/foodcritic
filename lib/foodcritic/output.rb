module FoodCritic

  # Default output showing a summary view.
  class SummaryOutput
    # Output a summary view only listing the matching rules, file and line
    # number.
    #
    # @param [Review] review The review to output.
    def output(review)
      puts review.to_s
    end
  end

  # Display rule matches with surrounding context.
  class ContextOutput

    # Output the review showing matching lines with context.
    #
    # @param [Review] review The review to output.
    def output(review)
      unless review.respond_to?(:warnings)
        puts review; return
      end

      # Cheating here and mis-using Rak (Ruby port of Ack) to generate pretty
      # colourised context.
      #
      # Rak supports evaluating a custom expression as an alternative to a
      # regex. Our expression consults a hash of the matches found and then we
      # let Rak take care of the presentation.
      line_lookup = key_by_file_and_line(review)
      Rak.class_eval do
        const_set(:RULE_COLOUR, "\033[1;36m")
        @warnings = line_lookup
      end
      ARGV.replace(['--context', '--eval', %q{
        # This code will be evaluated inline by Rak.
        fn = fn.split("\n").first
        if @warnings.key?(fn) and @warnings[fn].key?($.) # filename and line no
          rule_name = opt[:colour] ? RULE_COLOUR : ''
          rule_name += "#{@warnings[fn][$.].to_a.join("\n")}#{CLEAR_COLOURS}"
          if ! displayed_filename
            fn = "#{fn}\n#{rule_name}"
          else
            puts rule_name
          end
        else
          next
        end
      }, review.cookbook_paths])
      Rak.send(:remove_const, :VERSION) # Prevent duplicate VERSION warning
      load Gem.bin_path('rak', 'rak') # Assumes Rubygems
    end

    private

    # Build a hash lookup by filename and line number for warnings found in the
    # specified review.
    #
    # @param [Review] review The review to convert.
    # @return [Hash] Nested hashes keyed by filename and line number.
    def key_by_file_and_line(review)
      warn_hash = {}
      review.warnings.each do |warning|
        filename = Pathname.new(warning.match[:filename]).cleanpath.to_s
        line_num = warning.match[:line].to_i
        warn_hash[filename] = {} unless warn_hash.key?(filename)
        unless warn_hash[filename].key?(line_num)
          warn_hash[filename][line_num] = Set.new
        end
        warn_hash[filename][line_num] << warning.rule
      end
      warn_hash
    end

  end

end
