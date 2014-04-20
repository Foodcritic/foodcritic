module FoodCritic
  # Command line parsing.
  class CommandLine
    # Create a new instance of CommandLine
    #
    # @param [Array] args The command line arguments
    def initialize(args)
      @args = args
      @original_args = args.dup
      @options = {
        fail_tags: [],
        tags: [],
        include_rules: [],
        cookbook_paths: [],
        role_paths: [],
        environment_paths: [],
        exclude_paths: []
      }
      @parser = OptionParser.new do |opts|
        opts.banner = 'foodcritic [cookbook_paths]'
        opts.on('-t', '--tags TAGS',
                'Check against (or exclude ~) rules with the '\
                'specified tags.') do |t|
          @options[:tags] << t
        end
        opts.on('-f', '--epic-fail TAGS',
                "Fail the build based on tags. Use 'any' to fail "\
                'on all warnings.') do |t|
          @options[:fail_tags] << t
        end
        opts.on('-c', '--chef-version VERSION',
                'Only check against rules valid for this version '\
                'of Chef.') do |c|
          @options[:chef_version] = c
        end
        opts.on('-B', '--cookbook-path PATH',
                'Cookbook path(s) to check.') do |b|
          @options[:cookbook_paths] << b
        end
        opts.on('-C', '--[no-]context',
                'Show lines matched against rather than the '\
                'default summary.') do |c|
          @options[:context] = c
        end
        opts.on('-E', '--environment-path PATH',
                'Environment path(s) to check.') do |e|
          @options[:environment_paths] << e
        end
        opts.on('-I', '--include PATH',
                'Additional rule file path(s) to load.') do |i|
          @options[:include_rules] << i
        end
        opts.on('-G', '--search-gems',
                'Search rubygems for rule files with the path '\
                'foodcritic/rules/**/*.rb') do |g|
          @options[:search_gems] = true
        end
        opts.on('-R', '--role-path PATH',
                'Role path(s) to check.') do |r|
          @options[:role_paths] << r
        end
        opts.on('-S', '--search-grammar PATH',
                'Specify grammar to use when validating search syntax.') do |s|
          @options[:search_grammar] = s
        end
        opts.on('-V', '--version',
                'Display the foodcritic version.') do |v|
          @options[:version] = true
        end
        opts.on('-X', '--exclude PATH',
                'Exclude path(s) from being linted.') do |e|
          options[:exclude_paths] << e
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
      @args.length == 1 && @args.first == '--help'
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

    # If the paths provided are valid
    #
    # @return [Boolean] True if the paths exist.
    def valid_paths?
      paths = options[:cookbook_paths] + options[:role_paths] +
        options[:environment_paths]
      paths.any? && paths.all? { |path| File.exist?(path) }
    end

    # Is the search grammar specified valid?
    #
    # @return [Boolean] True if the grammar has not been provided or can be
    #   loaded.
    def valid_grammar?
      return true unless options.key?(:search_grammar)
      return false unless File.exist?(options[:search_grammar])
      search = FoodCritic::Chef::Search.new
      search.create_parser([options[:search_grammar]])
      search.parser?
    end

    # The cookbook paths to check
    #
    # @return [Array<String>] Path(s) to the cookbook(s) being checked.
    def cookbook_paths
      @args + Array(@options[:cookbook_paths])
    end

    # The role paths to check
    #
    # @return [Array<String>] Path(s) to the role directories being checked.
    def role_paths
      Array(@options[:role_paths])
    end

    # The environment paths to check
    #
    # @return [Array<String>] Path(s) to the environment directories checked.
    def environment_paths
      Array(@options[:environment_paths])
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
      original_options.merge(
        {
          cookbook_paths: cookbook_paths,
          role_paths: role_paths,
          environment_paths: environment_paths,
        }
      )
    end

    # The original command-line options
    #
    # @return [Hash] The original command-line options.
    def original_options
      @options
    end
  end
end
