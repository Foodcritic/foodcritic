module FoodCritic
  # Command line parsing.
  class CommandLine
    # Create a new instance of CommandLine
    #
    # @param [Array] args The command line arguments
    require "optparse"

    def initialize(args)
      # Load config_files first, so command line will override
      @args = args
      @original_args = args.dup
      @options = {
        fail_tags: [],
        tags: [],
        include_rules: [],
        cookbook_paths: [],
        role_paths: [],
        environment_paths: [],
        exclude_paths: [],
      }

      @parser = OptionParser.new do |opts|
        opts.banner = "foodcritic [cookbook_paths]"
        opts.on("-t", "--tags TAGS",
                "Check against (or exclude ~) rules with the "\
                "specified tags.") do |t|
          @options[:tags] << t
        end
        opts.on("-l", "--list",
                "List all enabled rules and their descriptions.") do |t|
          @options[:list] = t
        end
        opts.on("-f", "--epic-fail TAGS",
                "Fail the build based on tags. Use 'any' to fail "\
                "on all warnings.") do |t|
          @options[:fail_tags] << t
        end
        opts.on("-c", "--chef-version VERSION",
                "Only check against rules valid for this version "\
                "of Chef.") do |c|
          @options[:chef_version] = c
        end
        opts.on("-B", "--cookbook-path PATH",
                "Cookbook path(s) to check.") do |b|
          @options[:cookbook_paths] << b
        end
        opts.on("-C", "--[no-]context",
                "Show lines matched against rather than the "\
                "default summary.") do |c|
          @options[:context] = c
        end
        opts.on("-E", "--environment-path PATH",
                "Environment path(s) to check.") do |e|
          @options[:environment_paths] << e
        end
        opts.on("-I", "--include PATH",
                "Additional rule file path(s) to load.") do |i|
          @options[:include_rules] << i
        end
        opts.on("-G", "--search-gems",
                "Search rubygems for rule files with the path "\
                "foodcritic/rules/**/*.rb") do |g|
          @options[:search_gems] = true
        end
        opts.on("-P", "--progress",
                "Show progress of files being checked") do
          @options[:progress] = true
        end
        opts.on("-R", "--role-path PATH",
                "Role path(s) to check.") do |r|
          @options[:role_paths] << r
        end
        opts.on("-S", "--search-grammar PATH",
                "Specify grammar to use when validating search syntax.") do |s|
          @options[:search_grammar] = s
        end
        opts.on("-V", "--version",
                "Display the foodcritic version.") do |v|
          @options[:version] = true
        end
        opts.on("-X", "--exclude PATH",
                "Exclude path(s) from being linted. PATH is relative to the cookbook, not an absolute PATH") do |e|
          options[:exclude_paths] << e
        end
        opts.on("--config PATH",
                "Path to foodcritic.yml file to use") do |f|
          @options[:config] = f
        end
      end

      cbs = @parser.permute(args)

      get_config(cbs)

      @options[:fail_tags] = @fc_config["fail_tags"].flatten.uniq if @fc_config["fail_tags"]
      @options[:tags] = @fc_config["tags"].flatten.uniq if @fc_config["tags"]
      @options[:include_rules] = @fc_config["include_rules"].flatten.uniq if @fc_config["include_rules"]
      @options[:role_paths] = @fc_config["role_paths"].flatten.uniq if @fc_config["role_paths"]
      @options[:environment_paths] = @fc_config["environment_paths"].flatten.uniq if @fc_config["environment_paths"]
      @options[:exclude_paths] = @fc_config["exclude_paths"].flatten.uniq if @fc_config["exclude_paths"]
      @options[:cookbook_paths] = @fc_config["cookbook_paths"].flatten.uniq if @fc_config["cookbook_paths"]
      @options[:search_grammar] = @fc_config["search_grammar"] if @fc_config["search_grammar"]
      @options[:chef_version] = @fc_config["chef_version"] if @fc_config["chef_version"]
      @options[:context] = @fc_config["context"] if @fc_config["context"]
      @options[:search_gems] = @fc_config["search_gems"] if @fc_config["search_gems"]

      # -v is not implemented but OptionParser gives the Foodcritic's version
      # if that flag is passed
      if args.include? "-v"
        help
      else
        begin
          @parser.parse!(args) unless show_help?
        rescue OptionParser::InvalidOption => e
          e.recover args
        end
      end

      [:cookbook_paths, :role_paths, :environment_paths, :include_rules, :exclude_paths].each do |pth|
        @options[pth].map! { |c| File.expand_path(c, ".") } if @options[pth] && @options[pth] != [nil]
        @options[pth].flatten!
        @options[pth].uniq!
      end
    end

    # Search for and load config files
    def get_config(cbs)
      require "app_conf"
      files_to_load = []
      files_to_load << File.expand_path("~/.chef/foodcritic.yml", ".") if File.file?(File.expand_path("~/.chef/foodcritic.yml"))
      [".", cbs].flatten.each do |mypth|
        tmp_path = File.expand_path(mypth, ".")
        until File.basename(tmp_path) == "/"
          files_to_load << "#{tmp_path}/.chef/foodcritic.yml" if File.file?("#{tmp_path}/.chef/foodcritic.yml")
          tmp_path = File.expand_path("#{tmp_path}/..", ".")
        end
      end
      if @original_args.include?("--config")
        ind = @original_args.index("--config") + 1
        tmp_path = @original_args[ind]
        files_to_load << tmp_path if File.file?(tmp_path) && File.basename(tmp_path) == "foodcritic.yml"
        if File.directory?(tmp_path)
          files_to_load << "#{tmp_path}/foodcritic.yml" if File.file?("#{tmp_path}/foodcritic.yml")
          files_to_load << "#{tmp_path}/.chef/foodcritic.yml" if File.file?("#{tmp_path}/.chef/foodcritic.yml")
        end
      end

      files_to_load.flatten!
      files_to_load.uniq!

      @fc_config = {}
      tmp_config = AppConf.new
      files_to_load.each do |load_path|
        next unless File.exist?(load_path)
        tmp_config.load(load_path)
        @fc_config.merge!(tmp_config.to_hash) do |key, v1, v2|
          if v1 == v2
            v1
          elsif %w{chef_version config search_grammar search_gems context}.include? key
            v2 || v1
          elsif v1.class.name == "Array"
            v1 << v2 if v2
          else
            v1.each_line.to_a << v2 if v2
          end
        end
      end

      @fc_config.keys.each do |k|
        if %w{chef_version config search_grammar}.include?(k) && !@fc_config[k].class.name == "String"
          @fc_config[k] =  @fc_config[k].to_s
        elsif %w{search_gems context}.include?(k) && !@fc_config[k].class.name == "TrueClass" && !@fc_config[k].class.name == "FalseClass"
          @fc_config[k] = true if @fc_config[k]
        elsif %w{tags fail_tags include_rules role_paths environment_paths exclude_paths cookbook_paths}.include?(k)
          @fc_config[k] = Array(@fc_config[k])
        end
      end

      @fc_config
    end

    # Show the command help to the end user?
    #
    # @return [Boolean] True if help should be shown.
    def show_help?
      @args.length == 1 && @args.first == "--help"
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

    # Just list enabled rules, don't actually run a lint check?
    #
    # @return [Boolean] True if a rule listing is requested.
    def list_rules?
      @options.key?(:list)
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
      paths.flatten!
      if paths.any?
        tst = true
        paths.each do |path|
          if !path || path.nil? || !File.exist?(File.expand_path(path))
            tst = false
            puts "ERROR - Invalid path --#{path}--"
          end
        end
        return tst
      end
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

          cookbook_paths: cookbook_paths,
          role_paths: role_paths,
          environment_paths: environment_paths

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
