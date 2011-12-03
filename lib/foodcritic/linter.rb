require 'nokogiri'
require 'ripper'
require 'xmlsimple'

module FoodCritic

  # The main entry point for linting your Chef cookbooks.
  class Linter

    # Create a new Linter, loading any defined rules.
    def initialize
      load_rules
    end

    # Review the cookbooks at the provided path, identifying potential improvements.
    #
    # @param [String] cookbook_path The file path to an individual cookbook directory
    # @return [FoodCritic::Review] A review of your cookbooks, with any warnings issued.
    def check(cookbook_path)
      warnings = []
      files_to_process(cookbook_path).each do |file|
        ast = Nokogiri::XML(XmlSimple.xml_out(ast_to_hash(Ripper::SexpBuilder.new(IO.read(file)).parse)))
        @rules.each do |rule|
          rule.recipe.yield(ast).each do |match|
            warnings << Warning.new(rule, match.merge({:filename => file}))
          end
        end
      end
      Review.new(warnings)
    end

    private

    # If the provided node is the line / column information.
    #
    # @param [Nokogiri::XML::Node] node A node within the AST
    # @return [Boolean] True if this node holds the position data
    def position_node?(node)
      node.respond_to?(:length) and node.length == 2 and node.respond_to?(:all?) and node.all?{|child| child.respond_to?(:to_i)}
    end

    # Recurse the nested arrays provided by Ripper to create an intermediate Hash for ease of searching.
    #
    # @param [Nokogiri::XML::Node] node The AST
    # @return [Hash] The friendlier Hash.
    def ast_to_hash(node)
      result = {}
      if node.respond_to?(:each)
        node.drop(1).each do |child|
          if position_node?(child)
            result[:pos] = {:line => child.first, :column => child[1]}
          else
            if child.respond_to?(:first)
              result[child.first.to_s.gsub(/[^a-z_]/, '')] = ast_to_hash(child)
            else
              result[:value] = child  unless child.nil?
            end
          end
        end
      end
      result
    end

    # Load the rules from the (fairly unnecessary) DSL.
    def load_rules
      @rules = RuleDsl.load(File.join(File.dirname(__FILE__), 'rules.rb'))
    end

    # Return the files within a cookbook tree that we are interested in trying to match rules against.
    #
    # @param [String] dir The cookbook directory
    # @return [Array] The files underneath the provided directory to be processed.
    def files_to_process(dir)
      return [dir] unless File.directory? dir
      Dir.glob(File.join(dir, '{attributes,recipes}/*.rb')) + Dir.glob(File.join(dir, '*/{attributes,recipes}/*.rb'))
    end

  end
end