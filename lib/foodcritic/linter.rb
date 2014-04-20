require 'optparse'
require 'ripper'
require 'rubygems'
require 'set'

module FoodCritic
  # The main entry point for linting your Chef cookbooks.
  class Linter
    include FoodCritic::Api

    # The default version that will be used to determine relevant rules. This
    # can be over-ridden at the command line with the `--chef-version` option.
    DEFAULT_CHEF_VERSION = '11.10.4'
    attr_reader :chef_version

    # Perform a lint check. This method is intended for use by the command-line
    # wrapper. If you are programatically using foodcritic you should use
    # `#check` below.
    def self.check(cmd_line)
      # The first item is the string output, the second is exit code.
      return [cmd_line.help, 0] if cmd_line.show_help?
      return [cmd_line.version, 0] if cmd_line.show_version?
      if !cmd_line.valid_grammar?
        [cmd_line.help, 4]
      elsif cmd_line.valid_paths?
        review = FoodCritic::Linter.new.check(cmd_line.options)
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

      warnings = []; last_dir = nil; matched_rule_tags = Set.new
      load_rules
      paths = specified_paths!(options)

      # Loop through each file to be processed and apply the rules
      files_to_process(paths).each do |p|

        relevant_tags = if options[:tags].any?
                          options[:tags]
                        else
                          cookbook_tags(p[:filename])
                        end

        active_rules(relevant_tags).each do |rule|

          state = {
            path_type: p[:path_type],
            file: p[:filename],
            ast: read_ast(p[:filename]),
            rule: rule,
            last_dir: last_dir
          }

          matches = if p[:path_type] == :cookbook
                      cookbook_matches(state)
                    else
                      other_matches(state)
                    end

          matches = remove_ignored(matches, state[:rule], state[:file])

          # Convert the matches into warnings
          matches.each do |match|
            warnings << Warning.new(state[:rule],
                                    { filename: state[:file] }.merge(match),
                                    options)
            matched_rule_tags << state[:rule].tags
          end
        end
        last_dir = cookbook_dir(p[:filename])
      end

      Review.new(paths, warnings)
    end

    def cookbook_matches(state)
      cbk_matches = matches(state[:rule].recipe, state[:ast], state[:file])

      if dsl_method_for_file(state[:file])
        cbk_matches += matches(state[:rule].send(
          dsl_method_for_file(state[:file])), state[:ast], state[:file])
      end

      per_cookbook_rules(state[:last_dir], state[:file]) do
        if File.basename(state[:file]) == 'metadata.rb'
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
      rule_files = [File.join(File.dirname(__FILE__), 'rules.rb')]
      rule_files << options[:include_rules]
      rule_files << rule_files_in_gems if options[:search_gems]
      @rules = RuleDsl.load(rule_files.flatten.compact, chef_version)
    end

    private

    def rule_files_in_gems
      Gem::Specification.latest_specs(true).map do |spec|
        spec.matches_for_glob('foodcritic/rules/**/*.rb')
      end.flatten
    end

    def remove_ignored(matches, rule, file)
      matches.reject do |m|
        matched_file = m[:filename] || file
        (line = m[:line]) && File.exist?(matched_file) &&
           ignore_line_match?(File.readlines(matched_file)[line - 1], rule)
      end
    end

    def ignore_line_match?(line, rule)
      ignores = line.to_s[/\s+#\s*(.*)/, 1]
      if ignores && ignores.include?('~')
        !rule.matches_tags?(ignores.split(/[ ,]/))
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
      tags = []
      fc_file = "#{cookbook_dir(file)}/.foodcritic"
      if File.exist? fc_file
        begin
          tag_text = File.read fc_file
          tags = tag_text.split(/\s/)
        rescue Errno::EACCES
        end
      end
      tags
    end

    def active_rules(tags)
      @rules.select do |rule|
        rule.matches_tags?(tags) && applies_to_version?(rule, chef_version)
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
    def files_to_process(paths)
      paths.reject { |type, _| type == :exclude }.map do |path_type, dirs|
        dirs.map do |dir|
          exclusions = []

          unless paths[:exclude].empty?
            exclusions = Dir.glob(paths[:exclude].map do |p|
              File.join(dir, p, '**/**')
            end)
          end

          if File.directory?(dir)
            glob = if path_type == :cookbook
                     '{metadata.rb,{attributes,definitions,libraries,'\
                     'providers,recipes,resources}/*.rb,templates/*/*.erb}'
                   else
                     '*.rb'
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
          m.to_a.map { |m| match(m) }
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
        [key, Array(value)] if key.to_s.end_with?('paths')
      end.compact]

      unless paths.find { |k, v| k != :exclude_paths && !v.empty? }
        fail ArgumentError, 'A cookbook path or role path must be specified'
      end

      Hash[paths.map do |key, value|
        [key.to_s.sub(/_paths$/, '').to_sym, value]
      end]
    end

    def setup_defaults(options)
      { tags: [], fail_tags: [], include_rules: [], exclude_paths: [],
       cookbook_paths: [], role_paths: [] }.merge(options)
    end
  end
end
