module FoodCritic

  # Helper methods that form part of the Rules DSL.
  module Helpers

    # Create a match from the specified node.
    #
    # @param [Nokogiri::XML::Node] node The node to create a match for
    # @return [Hash] Hash with the matched node name and position with the recipe
    def match(node)
      pos = node.xpath('descendant::pos').first
      {:matched => node.name, :line => pos['line'], :column => pos['column']}
    end

    # Does the specified recipe check for Chef Solo?
    #
    # @param [Nokogiri::XML::Node] ast The AST of the cookbook recipe to check.
    # @return [Boolean] True if there is a test for Chef::Config[:solo] in the recipe
    def checks_for_chef_solo?(ast)
      ! ast.xpath(%q{//if/aref[count(descendant::const[@value = 'Chef' or @value = 'Config']) = 2 and
          count(descendant::ident[@value='solo']) > 0]}).empty?
    end

    # Searches performed by the specified recipe.
    #
    # @param [Nokogiri::XML::Node] ast The AST of the cookbook recipe to check.
    # @return [Boolean] True if the recipe performs a search
    def searches(ast)
      ast.xpath("//fcall/ident[@value = 'search']")
    end

    # Find Chef resources of the specified type.
    # TODO: Include blockless resources
    #
    # @param [Nokogiri::XML::Node] ast The AST of the cookbook recipe to check
    # @param [String] type The type of resource to look for (or nil for all resources)
    def find_resources(ast, type = nil)
      ast.xpath(%Q{//method_add_block[command/ident#{type.nil? ? '' : "[@value='#{type}']"}]})
    end

    # Return the type, e.g. 'package' for a given resource
    #
    # @param [Nokogiri::XML::Node] resource The resource AST
    # @return [String] The type of resource
    def resource_type(resource)
      resource.xpath('string(command/ident/@value)')
    end

    # Retrieve the name attribute associated with the specified resource.
    #
    # @param [Nokogiri::XML::Node] resource The resource AST to lookup the name attribute under
    def resource_name(resource)
      resource.xpath('string(command//tstring_content/@value)')
    end

    # Retrieve a single-valued attribute from the specified resource.
    #
    # @param [String] name The attribute name
    # @param [Nokogiri::XML::Node] resource The resource AST to lookup the attribute under
    # @return [String] The attribute value for the specified attribute
    def resource_attribute(name, resource)
      resource_attributes(resource)[name]
    end

    # Retrieve all attributes from the specified resource.
    #
    # @param [Nokogiri::XML::Node] resource The resource AST
    # @return [Hash] The resource attributes
    def resource_attributes(resource)
      atts = {:name => resource_name(resource)}
      resource.xpath('do_block/descendant::command').each do |att|
        if att.xpath('descendant::symbol').empty?
          att_value = att.xpath('string(descendant::tstring_content/@value)')
        else
          att_value = att.xpath('string(descendant::symbol/ident/@value)').to_sym
        end
        atts[att.xpath('string(ident/@value)')] = att_value
      end
      atts
    end

    # Retrieve all resources of a given type
    #
    # @param [Nokogiri::XML::Node] ast The recipe AST
    # @return [Hash] The matching resources
    def resources_by_type(ast)
      result = Hash.new{|hash, key| hash[key] = Array.new}
      find_resources(ast).each{|resource| result[resource_type(resource)] << resource}
      result
    end

    # Retrieve the attributes as a hash for all resources of a given type.
    #
    # @param [Nokogiri::XML::Node] ast The recipe AST
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
