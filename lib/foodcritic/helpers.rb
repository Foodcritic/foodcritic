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
      node.each { |n| result += ast(type, n) if n.respond_to?(:each) }
      result
    end

    # Does the specified recipe check for Chef Solo?
    #
    # @param [Array] ast The AST of the cookbook recipe to check.
    # @return [Boolean] True if there is a test for Chef::Config[:solo] in the recipe
    def checks_for_chef_solo?(ast)
      arefs = ast(:aref, ast)
      arefs.any? do |aref|
        ast(:@const, aref).map { |const| const[1] } == ['Chef', 'Config'] and
            ast(:@ident, ast(:symbol, aref)).map { |sym| sym.drop(1).first }.include? 'solo'
      end
    end

    # Find Chef resources of the specified type.
    # TODO: Include blockless resources
    #
    # @param [Array] ast The AST of the cookbook recipe to check
    # @param [String] type The type of resource to look for (or nil for all resources)
    def find_resources(ast, type = nil)
      ast(:method_add_block, ast).find_all do |resource|
        resource[1][0] == :command and resource[1][1][0] == :@ident and (type.nil? || resource[1][1][1] == type)
      end
    end

    # Return the type, e.g. 'package' for a given resource
    #
    # @param [Array] resource The resource AST
    # @return [String] The type of resource
    def resource_type(resource)
      resource[1][1][1]
    end

    # Retrieve the name attribute associated with the specified resource.
    #
    # @param [Array] resource The resource AST to lookup the name attribute under
    def resource_name(resource)
      ast(:@tstring_content, resource[1]).flatten[1]
    end

    # Retrieve a single-valued attribute from the specified resource.
    #
    # @param [String] name The attribute name
    # @param [Array] resource The resource AST to lookup the attribute under
    # @return [String] The attribute value for the specified attribute
    def resource_attribute(name, resource)
      cmd = ast(:command, ast(:do_block, resource))
      atts = cmd.find_all { |att| ast(:@ident, att).flatten.drop(1).first == name }
      value = ast(:@tstring_content, atts).flatten.drop(1)
      unless value.empty?
        return value.first
      end
      nil
    end

    # Retrieve all attributes from the specified resource.
    #
    # @param [Array] resource The resource AST
    # @return [Hash] The resource attributes
    def resource_attributes(resource)
      atts = {:name => resource_name(resource)}
      ast(:command, ast(:do_block, resource)).find_all{|cmd| cmd.first == :command}.each do |cmd|
        atts[cmd[1][1]] = ast(:@tstring_content, cmd[2]).flatten[1] || ast(:@ident, cmd[2]).flatten[1]
      end
      atts
    end

    # Retrieve all resources of a given type
    #
    # @param [Array] ast The recipe AST
    # @return [Array] The matching resources
    def resources_by_type(ast)
      result = Hash.new{|hash, key| hash[key] = Array.new}
      find_resources(ast).each{|resource| result[resource_type(resource)] << resource}
      result
    end

    # Retrieve the attributes as a hash for all resources of a given type.
    #
    # @param [Array] ast The recipe AST
    # @return [Hash] An array of resource attributes keyed by type.
    def resource_attributes_by_type(ast)
      result = {}
      resources_by_type(ast).each do |type,resources|
        result[type] = resources.map{|resource| resource_attributes(resource)}
      end
      result
    end
  end

end
