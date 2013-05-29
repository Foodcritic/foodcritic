require 'optparse'
require 'ripper'
require 'rubygems'
require 'gherkin/tag_expression'
require 'set'

module FoodCritic
  # The main entry point for linting your Chef cookbooks.
  class Linter

    include FoodCritic::Api

    # The default version that will be used to determine relevant rules. This
    # can be over-ridden at the command line with the `--chef-version` option.
    DEFAULT_CHEF_VERSION = "11.4.0"
    attr_reader :chef_version

    # Perform a lint check. This method is intended for use by the command-line
    # wrapper. If you are programatically using foodcritic you should use
    # `#check` below.
    def self.check(cmd_line)
      # The first item is the string output, the second is exit code.
      return [cmd_line.help, 0] if cmd_line.show_help?
      return [cmd_line.version, 0] if cmd_line.show_version?
      if ! cmd_line.valid_grammar?
        [cmd_line.help, 4]
      elsif cmd_line.valid_paths?
        review = FoodCritic::Linter.new.check(cmd_line.cookbook_paths,
          cmd_line.options)
        [review, review.failed? ? 3 : 0]
      else
        [cmd_line.help, 2]
      end
    end

    # Review the cookbooks at the provided path, identifying potential
    # improvements.
    #
    # The `options` are a hash where the valid keys are:
    #
    # * `:include_rules` - Paths to additional rules to apply
    # * `:tags` - The tags to filter rules based on
    # * `:fail_tags` - The tags to fail the build on
    # * `:exclude_paths` - Paths to exclude from linting
    #
    def check(cookbook_paths, options = {})

      cookbook_paths = sanity_check_cookbook_paths(cookbook_paths)
      options = setup_defaults(options)
      @options = options
      @chef_version = options[:chef_version] || DEFAULT_CHEF_VERSION

      warnings = []; last_dir = nil; matched_rule_tags = Set.new

      load_rules

      # Loop through each file to be processed and apply the rules
      files_to_process(cookbook_paths, options[:exclude_paths]).each do |file|
        ast = read_ast(file)
        relevant_tags = options[:tags].any? ? options[:tags] : cookbook_tags(file)
        active_rules(relevant_tags).each do |rule|
          rule_matches = matches(rule.recipe, ast, file)

          if dsl_method_for_file(file)
            rule_matches += matches(rule.send(dsl_method_for_file(file)),
              ast, file)
          end

          per_cookbook_rules(last_dir, file) do
            if File.basename(file) == 'metadata.rb'
              rule_matches += matches(rule.metadata, ast, file)
            end
            rule_matches += matches(rule.cookbook, cookbook_dir(file))
          end

          rule_matches = remove_ignored(rule_matches, rule, file)

          # Convert the matches into warnings
          rule_matches.each do |match|
            warnings << Warning.new(rule, {:filename => file}.merge(match))
            matched_rule_tags << rule.tags
          end
        end
        last_dir = cookbook_dir(file)
      end

      Review.new(cookbook_paths, warnings,
        should_fail_build?(options[:fail_tags], matched_rule_tags))
    end

    # Load the rules from the (fairly unnecessary) DSL.
    def load_rules
      load_rules!(@options) unless defined? @rules
    end

    def load_rules!(options)
      @rules = RuleDsl.load([File.join(File.dirname(__FILE__), 'rules.rb')] +
        options[:include_rules], chef_version)
    end

    private

    def remove_ignored(matches, rule, file)
      matches.reject do |m|
        matched_file = m[:filename] || file
        (line = m[:line]) && File.exist?(matched_file) &&
           ignore_line_match?(File.readlines(matched_file)[line-1], rule)
      end
    end

    def ignore_line_match?(line, rule)
      ignores = line.to_s[/\s+#\s*(.*)/, 1]
      if ignores and ignores.include?('~')
        ! matching_tags?(ignores.split(/[ ,]/), rule.tags)
      else
        false
      end
    end

    # Some rules are version specific.
    def applies_to_version?(rule, version)
      return true unless version
      rule.applies_to.yield(Gem::Version.create(version))
    end

    def cookbook_tags(file)
      fc_file = "#{cookbook_dir(file)}/.foodcritic"
      tag_text = File.read fc_file
      tag_text.split(/\s/)
    rescue Errno::ENOENT, Errno::EACCES
      []
    end

    def active_rules(tags)
      @rules.select do |rule|
        matching_tags?(tags, rule.tags) and
        applies_to_version?(rule, chef_version)
      end
    end

    def cookbook_dir(file)
      Pathname.new(File.join(File.dirname(file),
        case File.basename(file)
          when 'metadata.rb' then ''
          when /\.erb$/ then '../..'
          else '..'
        end)).cleanpath
    end

    def dsl_method_for_file(file)
      dir_mapping = {
        'attributes' => :attributes,
        'libraries' => :library,
        'providers' => :provider,
        'resources' => :resource,
        'templates' => :template
      }
      if file.end_with? '.erb'
        dir_mapping[File.basename(File.dirname(File.dirname(file)))]
      else
        dir_mapping[File.basename(File.dirname(file))]
      end
    end

    # Return the files within a cookbook tree that we are interested in trying
    # to match rules against.
    def files_to_process(dirs, exclude_paths = [])
      files = []
      dirs.each do |dir|
        exclusions = Dir.glob(exclude_paths.map{|p| File.join(dir, p)})
        if File.directory? dir
          cookbook_glob = '{metadata.rb,{attributes,libraries,providers,recipes,resources}/*.rb,templates/*/*.erb}'
          files += (Dir.glob(File.join(dir, cookbook_glob)) +
            Dir.glob(File.join(dir, "*/#{cookbook_glob}")) - exclusions)
        else
          files << dir unless exclusions.include?(dir)
        end
      end
      files
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
          m.to_a.map{|m| match(m)}
        else
          m
        end
      end.flatten
    end

    # We use the Gherkin (Cucumber) syntax to specify tags.
    def matching_tags?(tag_expr, tags)
      Gherkin::TagExpression.new(tag_expr).evaluate(tags.map do |t|
        Gherkin::Formatter::Model::Tag.new(t, 1)
      end)
    end

    def per_cookbook_rules(last_dir, file)
      yield if last_dir != cookbook_dir(file)
    end

    def sanity_check_cookbook_paths(cookbook_paths)
      raise ArgumentError, "Cookbook paths are required" if cookbook_paths.nil?
      cookbook_paths = Array(cookbook_paths)
      if cookbook_paths.empty?
        raise ArgumentError, "Cookbook paths cannot be empty"
      end
      cookbook_paths
    end

    def setup_defaults(options)
      {:tags => [], :fail_tags => [],
                 :include_rules => [], :exclude_paths => []}.merge(options)
    end

    def should_fail_build?(fail_tags, matched_tags)
      return false if fail_tags.empty?
      matched_tags.any?{|tags| matching_tags?(fail_tags, tags)}
    end

  end
end
