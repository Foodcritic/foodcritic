module FoodCritic

  # Command line parsing.
  class CommandLine

    include FoodCritic::Chef::Search

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
        opts.on("-S", "--search-grammar PATH", "Specify grammar to use when validating search syntax.") {|s|options[:search_grammar] = s}
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

    # Is the search grammar specified valid?
    #
    # @return [Boolean] True if the grammar has not been provided or can be loaded.
    def valid_grammar?
      return true unless options.key?(:search_grammar)
      return false unless File.exists?(options[:search_grammar])
      load_search_parser([options[:search_grammar]])
      search_parser_loaded?
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
