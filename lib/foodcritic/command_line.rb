module FoodCritic

  # Command line parsing.
  class CommandLine

    # Create a new instance of CommandLine
    #
    # @param [Array] args The command line arguments
    def initialize(args)
      @args = args
      @original_args = args.dup
      @options = {:fail_tags => [], :tags => [], :include_rules => []}
      @parser = OptionParser.new do |opts|
        opts.banner = 'foodcritic [cookbook_paths]'
        opts.on("-t", "--tags TAGS",
          "Only check against rules with the specified tags.") do |t|
          options[:tags] << t
        end
        opts.on("-f", "--epic-fail TAGS",
          "Fail the build if any of the specified tags are matched ('any' -> fail on any match).") do |t|
          options[:fail_tags] << t
        end
        opts.on("-c", "--chef-version VERSION",
          "Only check against rules valid for this version of Chef.") do |c|
          options[:chef_version] = c
        end
        opts.on("-C", "--[no-]context",
          "Show lines matched against rather than the default summary.") do |c|
          options[:context] = c
        end
        opts.on("-I", "--include PATH",
          "Additional rule file path(s) to load.") do |i|
          options[:include_rules] << i
        end
        opts.on("-S", "--search-grammar PATH",
          "Specify grammar to use when validating search syntax.") do |s|
          options[:search_grammar] = s
        end
        opts.on("-V", "--version",
          "Display the foodcritic version.") do |v|
          options[:version] = true
        end
      end
      # -v is not implemented but OptionParser gives the Foodcritic's version
      # if that flag is passed
      if args.include? '-v'
        help
      else
        begin
          @parser.parse!(args) unless show_help?
        rescue OptionParser::InvalidOption => e
          e.recover args
        end
      end
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

    # Show the current version to the end user?
    #
    # @return [Boolean] True if the version should be shown.
    def show_version?
      @options.key?(:version)
    end

    # The version string.
    #
    # @return [String] Current installed version.
    def version
      "foodcritic #{FoodCritic::VERSION}"
    end

    # If the cookbook path provided is valid
    #
    # @deprecated Multiple cookbook paths may be provided.
    # @return [Boolean] True if the path exists.
    def valid_path?
      @args.length == 1 and File.exists?(@args[0])
    end

    # If the cookbook paths provided are valid
    #
    # @return [Boolean] True if the paths exist.
    def valid_paths?
      @args.any? && @args.all? {|path| File.exists?(path) }
    end

    # The cookbook path.
    #
    # @deprecated Multiple cookbook paths may be provided.
    # @return [String] Path to the cookbook(s) being checked.
    def cookbook_path
      @args[0]
    end

    # The cookbook paths
    #
    # @return [Array<String>] Path(s) to the cookbook(s) being checked.
    def cookbook_paths
      @args
    end

    # Is the search grammar specified valid?
    #
    # @return [Boolean] True if the grammar has not been provided or can be
    #   loaded.
    def valid_grammar?
      return true unless options.key?(:search_grammar)
      return false unless File.exists?(options[:search_grammar])
      search = FoodCritic::Chef::Search.new
      search.create_parser([options[:search_grammar]])
      search.parser?
    end

    # If matches should be shown with context rather than the default summary
    # display.
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
