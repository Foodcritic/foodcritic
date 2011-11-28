module FoodCritic

  # Helper methods that form part of the Rules DSL.
  module Helpers

    # Given an AST type and parsed tree, return the matching subset.
    #
    # @param [Symbol] type The type of AST node to look for
    # @param [Array] node The parsed AST (or part there-of)
    # @return [Array] Matching nodes
    def ast(type, node)
      result = []
      result = [node] if node.first == type
      node.each { |node| result += ast(type, node) if node.respond_to?(:each) }
      result
    end

    # Does the specified recipe check for Chef Solo?
    #
    # @param [Array] ast The AST of the cookbook recipe to check.
    # @return [Boolean] True if there is a test for Chef::Config[:solo] in the recipe
    def checks_for_chef_solo?(ast)
      arefs = self.ast(:aref, ast)
      arefs.any? do |aref|
        self.ast(:@const, aref).map { |const| const[1] } == ['Chef', 'Config'] and
            self.ast(:@ident, self.ast(:symbol, aref)).map { |sym| sym.drop(1).first }.include? 'solo'
      end
    end

    # Find Chef resources of the specified type
    #
    # @param [Array] ast The AST of the cookbook recipe to check
    # @param [String] type The type of resource to look for
    def find_resources(ast, type)
      self.ast(:method_add_block, ast).find_all do |resource|
        resource[1][0] == :command and resource[1][1][0] == :@ident and resource[1][1][1] == type
      end
    end

    # Retrieve a single-valued attribute from the specified resource.
    #
    # @param name The attribute name
    # @param resource The resource AST to lookup the attribute under
    # @return [String] The attribute value for the specified attribute
    def resource_attribute(name, resource)
      cmd = self.ast(:command, self.ast(:do_block, resource))
      atts = cmd.find_all { |att| ast(:@ident, att).flatten.drop(1).first == name }
      value = self.ast(:@tstring_content, atts).flatten.drop(1)
      unless value.empty?
        return value.first
      end
      nil
    end
  end

end
