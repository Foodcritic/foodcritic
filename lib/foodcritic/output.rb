require 'set'

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

      context = 3

      print_fn = lambda { |fn| ansi_print(fn, :red, nil, :bold) }
      print_rule = lambda { |warn| ansi_print(warn, :cyan, nil, :bold) }
      print_line = lambda { |line| ansi_print(line, nil, :red, :bold) }

      key_by_file_and_line(review).each do |fn, warnings|
        print_fn.call fn
        unless File.exist?(fn)
          print_rule.call warnings[1].to_a.join("\n")
          next
        end

        # Set of line numbers with warnings
        warn_lines = warnings.keys.to_set
        # Moving set of line numbers within the context of our position
        context_set = (0..context).to_set
        # The last line number we printed a warning for
        last_warn = -1

        File.open(fn) do |file|
          file.each do |line|
            context_set.add(file.lineno + context)
            context_set.delete(file.lineno - context - 1)

            # Find the first warning within our context
            context_warns = context_set & warn_lines
            next_warn = context_warns.min
            # We may need to interrupt the trailing context
            # of a previous warning
            next_warn = file.lineno if warn_lines.include? file.lineno

            # Display a warning
            if next_warn && next_warn > last_warn
              print_rule.call warnings[next_warn].to_a.join("\n")
              last_warn = next_warn
            end

            # Display any relevant lines
            if warn_lines.include? file.lineno
              print '%4i|' % file.lineno
              print_line.call line.chomp
            elsif not context_warns.empty?
              print '%4i|' % file.lineno
              puts line.chomp
            end
          end
        end
      end
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

    # Print an ANSI escape-code formatted string (and a newline)
    #
    # @param text [String] the string to format
    # @param fg [String] foreground color
    # @param bg [String] background color
    # @param attr [String] any formatting options
    def ansi_print(text, fg, bg = nil, attr = nil)
      unless STDOUT.tty?
        puts text
        return
      end

      colors = %w(black red green yellow blue magenta cyan white)
      attrs = %w(reset bold dim underscore blink reverse hidden)
      escape = "\033[%sm"
      fmt = []
      fmt << 30 + colors.index(fg.to_s) if fg
      fmt << 40 + colors.index(bg.to_s) if bg
      fmt << attrs.index(attr.to_s) if attr
      if fmt
        puts "#{escape % fmt.join(';')}#{text}#{escape % 0}"
      else
        puts text
      end
    end
  end
end
