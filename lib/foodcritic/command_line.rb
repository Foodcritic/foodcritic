module FoodCritic

  # Command line parsing.
  class CommandLine

    # Create a new instance of CommandLine
    #
    # @param [Array] args The command line arguments
    def initialize(args)
      @args = args
      @options = {}
      @options[:fail_tags] = []; @options[:tags] = []
      @parser = OptionParser.new do |opts|
        opts.banner = 'foodcritic [cookbook_path]'
        opts.on("-r", "--[no-]repl", "Drop into a REPL for interactive rule editing.") {|r|options[:repl] = r}
        opts.on("-t", "--tags TAGS", "Only check against rules with the specified tags.") {|t|options[:tags] << t}
        opts.on("-f", "--epic-fail TAGS", "Fail the build if any of the specified tags are matched.") {|t|options[:fail_tags] << t}
        opts.on("-C", "--[no-]context", "Show lines matched against rather than the default summary.") {|c|options[:context] = c}
      end
      @parser.parse!(args) unless show_help?
    end

    # Show the command help to the end user?
    #
    # @return [Boolean] True if help should be shown.
    def show_help?
      @args.length == 1 and @args.first == '--help'
    end

    # The help text.
    #
    # @return [String] Help text describing the command-line options available.
    def help
      @parser.help
    end

    # If the cookbook path provided is valid
    #
    # @return [Boolean] True if the path is a directory that exists.
    def valid_path?
      @args.length == 1 and Dir.exists?(@args[0])
    end

    # The cookbook path
    #
    # @return [String] Path to the cookbook(s) being checked.
    def cookbook_path
      @args[0]
    end

    # If matches should be shown with context rather than the default summary display.
    #
    # @return [Boolean] True if matches should be shown with context.
    def show_context?
      @options[:context]
    end

    # Parsed command-line options
    #
    # @return [Hash] The parsed command-line options.
    def options
      @options
    end

  end

end