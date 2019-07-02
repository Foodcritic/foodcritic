require "optparse"
require "ripper"
require "set"

module FoodCritic
  # The main entry point for linting your Chef cookbooks.
  class Linter
    include FoodCritic::Api

    # The default version that will be used to determine relevant rules. This
    # can be over-ridden at the command line with the `--chef-version` option.
    DEFAULT_CHEF_VERSION = "15.0.293".freeze
    attr_reader :chef_version

    # Perform a lint check. This method is intended for use by the command-line
    # wrapper. If you are programmatically using foodcritic you should use
    # `#check` below.
    def self.run(cmd_line)
      # The first item is the string output, the second is exit code.
      return [cmd_line.help, 0] if cmd_line.show_help?
      return [cmd_line.version, 0] if cmd_line.show_version?
      if !cmd_line.valid_grammar?
        [cmd_line.help, 4]
      elsif cmd_line.list_rules?
        listing = FoodCritic::Linter.new.list(cmd_line.options)
        [listing, 0]
      elsif cmd_line.valid_paths?
        review = FoodCritic::Linter.new.check(cmd_line.options)
        [review, review.failed? ? 3 : 0]
      else
        [cmd_line.help, 2]
      end
    end

    # List the rules that are currently in effect.
    #
    # The `options` are a hash where the valid keys are:
    #
    # * `:include_rules` - Paths to additional rules to apply
    # * `:search_gems - If true then search for custom rules in installed gems.
    # * `:tags` - The tags to filter rules based on
    def list(options = {})
      options = setup_defaults(options)
      @options = options
      load_rules

      if options[:tags].any?
        @rules = active_rules(options[:tags])
      end

      RuleList.new(@rules)
    end

    # Review the cookbooks at the provided path, identifying potential
    # improvements.
    #
    # The `options` are a hash where the valid keys are:
    #
    # * `:cookbook_paths` - Cookbook paths to lint
    # * `:role_paths` - Role paths to lint
    # * `:include_rules` - Paths to additional rules to apply
    # * `:search_gems - If true then search for custom rules in installed gems.
    # * `:tags` - The tags to filter rules based on
    # * `:fail_tags` - The tags to fail the build on
    # * `:exclude_paths` - Paths to exclude from linting
    #
    def check(options = {})
      options = setup_defaults(options)
      @options = options
      @chef_version = options[:chef_version] || DEFAULT_CHEF_VERSION
      ast_cache(options[:ast_cache_size])

      warnings = []; last_dir = nil; matched_rule_tags = Set.new
      load_rules
      paths = specified_paths!(options)

      # Loop through each file to be processed and apply the rules
      files = files_to_process(paths)

      if options[:progress]
        puts "Checking #{files.count} files"
      end

      files.each do |p|
        relevant_tags = if options[:tags].any?
                          options[:tags]
                        else
                          rule_file_tags(p[:filename])
                        end

        progress = "."

        active_rules(relevant_tags).each do |rule|
          state = {
            path_type: p[:path_type],
            file: p[:filename],
            ast: read_ast(p[:filename]),
            rule: rule,
            last_dir: last_dir,
          }

          matches = if p[:path_type] == :cookbook
                      cookbook_matches(state)
                    else
                      other_matches(state)
                    end

          matches = remove_ignored(matches, state[:rule], state[:file])

          progress = "x" if matches.any?

          # Convert the matches into warnings
          matches.each do |match|
            warnings << Warning.new(state[:rule],
                                    { filename: state[:file] }.merge(match),
                                    options)
            matched_rule_tags << state[:rule].tags
          end
        end

        putc progress if options[:progress]

        last_dir = cookbook_dir(p[:filename])
      end

      puts "" if options[:progress]

      Review.new(paths, warnings)
    end

    def cookbook_matches(state)
      cbk_matches = matches(state[:rule].recipe, state[:ast], state[:file])

      if dsl_method_for_file(state[:file])
        cbk_matches += matches(state[:rule].send(
          dsl_method_for_file(state[:file])), state[:ast], state[:file])
      end

      per_cookbook_rules(state[:last_dir], state[:file]) do
        if File.basename(state[:file]) == "metadata.rb"
          cbk_matches += matches(
            state[:rule].metadata, state[:ast], state[:file])
        end
        cbk_matches += matches(
          state[:rule].cookbook, cookbook_dir(state[:file]))
      end

      cbk_matches
    end

    def other_matches(state)
      matches(state[:rule].send(state[:path_type]), state[:ast], state[:file])
    end

    # Load the rules from the (fairly unnecessary) DSL.
    def load_rules
      load_rules!(@options) unless defined? @rules
    end

    def load_rules!(options)
      rule_files = Dir.glob(File.join(File.dirname(__FILE__), "rules", "*"))
      rule_files << options[:include_rules]
      rule_files << rule_files_in_gems if options[:search_gems]
      @rules = RuleDsl.load(rule_files.flatten.compact, chef_version)
    end

    private

    def rule_files_in_gems
      Gem::Specification
        .latest_specs(true)
        .reject { |spec| spec.name == "foodcritic" }
        .map { |spec| spec.matches_for_glob("foodcritic/rules/**/*.rb") }
        .flatten
    end

    def remove_ignored(matches, rule, file)
      matches.reject do |m|
        matched_file = m[:filename] || file
        (line = m[:line]) && File.exist?(matched_file) &&
          !File.directory?(matched_file) &&
          ignore_line_match?(File.readlines(matched_file)[line - 1], rule)
      end
    end

    def ignore_line_match?(line, rule)
      ignores = line.to_s[/.*#\s*(.*)/, 1]
      if ignores && ignores.include?("~")
        !rule.matches_tags?(ignores.split(/[ ,]/))
      else
        false
      end
    rescue
      false
    end

    # Some rules are version specific.
    def applies_to_version?(rule, version)
      return true unless version
      rule.applies_to.yield(Gem::Version.create(version))
    end

    # given a file in the cookbook lookup all the applicable tag rules defined in rule
    # files. The rule file is either that specified via CLI or the .foodcritic file
    # in the cookbook. We cache this information at the cookbook level to prevent looking
    #  up the same thing dozens of times
    #
    # @param [String] file in the cookbook
    # @return [Array] array of tag rules
    def rule_file_tags(file)
      cookbook = cookbook_dir(file)
      @tag_cache ||= {}

      # lookup the tags in the cache has and return that if we find something
      cb_tags = @tag_cache[cookbook]
      return cb_tags unless cb_tags.nil?

      # if a rule file has been specified use that. Otherwise use the .foodcritic file in the CB
      tags = if @options[:rule_file]
               raise "ERROR: Could not find the specified rule file at #{@options[:rule_file]}" unless File.exist?(@options[:rule_file])
               parse_rule_file(@options[:rule_file])
             else
               File.exist?("#{cookbook}/.foodcritic") ? parse_rule_file("#{cookbook}/.foodcritic") : []
             end

      @tag_cache[cookbook] = tags
      tags
    end

    # given a filename parse any tag rules in that file
    #
    # @param [String] rule file path
    # @return [Array] array of tag rules from the file
    def parse_rule_file(file)
      tags = []
      begin
        tag_text = File.read file
        tags = tag_text.split(/\s/)
      rescue
        raise "ERROR: Could not read or parse the specified rule file at #{file}"
      end
      tags
    end

    def active_rules(tags)
      @rules.select do |rule|
        rule.matches_tags?(tags) && applies_to_version?(rule, chef_version)
      end
    end

    # provides the path to the cookbook from a file within the cookbook
    # we cache this data in a hash because this method gets called often
    # for the same files.
    #
    # @param [String] file - a file path in the cookbook
    # @return [String] the path to the cookbook
    def cookbook_dir(file)
      @dir_cache ||= {}
      abs_file = File.absolute_path(file)

      # lookup the file in the cache has and return that if we find something
      cook_val = @dir_cache[abs_file]
      return cook_val unless cook_val.nil?

      if file =~ /\.erb$/
        # split each directory into an item in the array
        dir_array = File.dirname(file).split(File::SEPARATOR)

        # walk through the array of directories backwards until we hit the templates directory
        position = -1
        position -= 1 until dir_array[position] == "templates"

        # go back 1 more position to get to the cookbook dir
        position -= 1

        # slice from the start to the cookbook dir and then join it all back to a string
        cook_val = dir_array.slice(0..position).join(File::SEPARATOR)
      else
        # determine the difference to the root of the CB from our file's directory
        relative_difference = case File.basename(file)
                              when "recipe.rb", "attributes.rb", "metadata.rb" then ""
                              else # everything else is 1 directory up ie. cookbook/recipes/default.rb
                                ".."
                              end

        cook_val = Pathname.new(File.join(File.dirname(file), relative_difference)).cleanpath
      end

      @dir_cache[abs_file] = cook_val
      cook_val
    end

    def dsl_method_for_file(file)
      dir_mapping = {
        "attributes" => :attributes,
        "libraries" => :library,
        "providers" => :provider,
        "resources" => :resource,
        "templates" => :template,
      }
      if file.end_with? ".erb"
        dir_mapping[File.basename(File.dirname(File.dirname(file)))]
      else
        dir_mapping[File.basename(File.dirname(file))]
      end
    end

    # Return the files within a cookbook tree that we are interested in trying to match rules against.
    #
    # @param [Hash] paths - paths of interest: {:exclude=>[], :cookbook=>[], :role=>[], :environment=>[]}
    # @return [Array] array of hashes for each file {:filename=>"./metadata.rb", :path_type=>:cookbook}
    def files_to_process(paths)
      paths.reject { |type, _| type == :exclude }.map do |path_type, dirs|
        dirs.map do |dir|
          exclusions = []

          unless paths[:exclude].empty?
            exclusions = Dir.glob(paths[:exclude].map do |p|
              File.join(dir, p, "**/**")
            end)
          end

          if File.directory?(dir)
            glob = if path_type == :cookbook
                     "{metadata.rb,attributes.rb,recipe.rb,{attributes,definitions,libraries,"\
                     "providers,recipes,resources}/*.rb,templates/**/*.erb}"
                   else
                     "*.rb"
                   end

            (Dir.glob(File.join(dir, glob)) +
             Dir.glob(File.join(dir, "*/#{glob}")) - exclusions)
          else
            dir unless exclusions.include?(dir)
          end
        end.compact.flatten.map do |filename|
          { filename: filename, path_type: path_type }
        end
      end.flatten
    end

    # Invoke the DSL method with the provided parameters.
    def matches(match_method, *params)
      return [] unless match_method.respond_to?(:yield)
      matches = match_method.yield(*params)
      return [] unless matches.respond_to?(:each)

      # We convert Nokogiri nodes to matches transparently
      matches.map do |m|
        if m.respond_to?(:node_name)
          match(m)
        elsif m.respond_to?(:xpath)
          m.to_a.map { |n| match(n) }
        else
          m
        end
      end.flatten
    end

    def per_cookbook_rules(last_dir, file)
      yield if last_dir != cookbook_dir(file)
    end

    def specified_paths!(options)
      paths = Hash[options.map do |key, value|
        [key, Array(value)] if key.to_s.end_with?("paths")
      end.compact]

      unless paths.find { |k, v| k != :exclude_paths && !v.empty? }
        raise ArgumentError, "A cookbook path or role path must be specified"
      end

      Hash[paths.map do |key, value|
        [key.to_s.sub(/_paths$/, "").to_sym, value]
      end]
    end

    def setup_defaults(options)
      { tags: [], fail_tags: [], include_rules: [], exclude_paths: [],
        cookbook_paths: [], role_paths: [] }.merge(options)
    end
  end
end
