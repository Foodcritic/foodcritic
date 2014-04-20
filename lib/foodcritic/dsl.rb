require 'pathname'

module FoodCritic
  # The DSL methods exposed for defining rules. A minimal example rule:
  #
  #     rule "FC123", "My rule name" do
  #       tags %w{style attributes}
  #         recipe do |ast|
  #           ## Rule implementation body
  #         end
  #     end
  #
  # * Each rule is defined within a `rule` block that defines the code and name
  #   of the rule.
  # * Each rule block may contain further nested blocks for the components of
  #   the cookbook that it is interested in linting.
  #   For example `cookbook`, `recipe` or `library`.
  #
  # * Further DSL methods are available to define the `tags` and Chef versions
  #   the rule `applies_to`.
  #

  class RuleDsl
    attr_reader :rules
    attr_reader :chef_version

    include Api

    def initialize(chef_version = Linter::DEFAULT_CHEF_VERSION)
      @chef_version = chef_version
    end

    # Define a new rule, the outer block of a rule definition.
    def rule(code, name, &block)
      @rules = [] if @rules.nil?
      @rules << Rule.new(code, name)
      yield self
    end

    # Add tags to the rule which can be used by the end user to filter the
    # rules to be applied.
    def tags(tags)
      rules.last.tags += tags
    end

    # Alternative to tags. Commonly used to constrain a rule to run only when
    # linting specific Chef versions.
    def applies_to(&block)
      rules.last.applies_to = block
    end

    def self.rule_block(name)
      define_method(name) do |&block|
        rules.last.send("#{name}=".to_sym, block)
      end
    end

    # The most frequently used block within a rule. A slight misnomer because
    # `recipe` rule blocks are also evaluated against providers.
    rule_block :recipe


    rule_block :cookbook
    rule_block :metadata
    rule_block :resource
    rule_block :attributes
    rule_block :provider
    rule_block :library
    rule_block :template

    rule_block :environment
    rule_block :role

    # Load the ruleset(s).
    def self.load(paths, chef_version = Linter::DEFAULT_CHEF_VERSION)
      dsl = RuleDsl.new(chef_version)
      paths.map do |path|
        File.directory?(path) ? Dir["#{path}/**/*.rb"].sort : path
      end.flatten.each do |path|
        dsl.instance_eval(File.read(path), path)
      end
      dsl.rules
    end
  end
end
