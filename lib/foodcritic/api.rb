require 'nokogiri'

module FoodCritic

  # Helper methods that form part of the Rules DSL.
  module Api

    include FoodCritic::Chef

    # Find attribute accesses by type.
    #
    # @param [Nokogiri::XML::Node] ast The AST of the cookbook recipe to check
    # @param [Symbol] type The approach used to access the attributes
    #   (:string, :symbol or :vivified).
    # @param [Boolean] ignore_calls Exclude attribute accesses that mix
    #   strings/symbols with dot notation. Defaults to false.
    # @return [Array] The matching nodes if any
    def attribute_access(ast, options = {})
      options = {:type => :any, :ignore_calls => false}.merge!(options)
      return [] unless ast.respond_to?(:xpath)
      unless [:string, :symbol, :vivified].include?(options[:type])
        raise ArgumentError, "Node type not recognised"
      end

      if options[:type] == :vivified
        vivified_attribute_access(ast)
      else
        standard_attribute_access(ast, options)
      end
    end

    # Does the specified recipe check for Chef Solo?
    #
    # @param [Nokogiri::XML::Node] ast The AST of the cookbook recipe to check.
    # @return [Boolean] True if there is a test for Chef::Config[:solo] in the
    #   recipe
    def checks_for_chef_solo?(ast)
      raise_unless_xpath!(ast)
      ! ast.xpath(%q{//if/aref[count(descendant::const[@value = 'Chef' or
          @value = 'Config']) = 2
          and count(descendant::ident[@value='solo']) > 0]}).empty?
    end

    # Is the chef-solo-search library available?
    #
    # @param [String] recipe_path The path to the current recipe
    # @return [Boolean] True if the chef-solo-search library is available.
    def chef_solo_search_supported?(recipe_path)
      return false if recipe_path.nil? || ! File.exists?(recipe_path)
      cbk_tree_path = Pathname.new(File.join(recipe_path, '../../..'))
      search_libs = Dir[File.join(cbk_tree_path.realpath,
        '*/libraries/search.rb')]
      search_libs.any? do |lib|
        ! read_ast(lib).xpath(%q{//class[count(descendant::const[@value='Chef']
          ) = 1]/descendant::def/ident[@value='search']}).empty?
      end
    end

    # The name of the cookbook containing the specified file.
    #
    # @param [String] file The file in the cookbook
    # @return [String] The name of the containing cookbook
    def cookbook_name(file)
      raise ArgumentError, 'File cannot be nil or empty' if file.to_s.empty?
      until (file.split(File::SEPARATOR) & standard_cookbook_subdirs).empty? do
        file = File.absolute_path(File.dirname(file.to_s))
      end
      file = File.dirname(file) unless File.extname(file).empty?
      md_path = File.join(file, 'metadata.rb')
      if File.exists?(md_path)
        name = read_ast(md_path).xpath("//stmts_add/
          command[ident/@value='name']/descendant::tstring_content/@value").to_s
        return name unless name.empty?
      end
      File.basename(file)
    end

    # The dependencies declared in cookbook metadata.
    #
    # @param [Nokogiri::XML::Node] ast The metadata rb AST
    # @return [Array] List of cookbooks depended on
    def declared_dependencies(ast)
      raise_unless_xpath!(ast)
      deps = ast.xpath(%q{//command[ident/@value='depends']/
        descendant::args_add/descendant::tstring_content[1]})
      # handle quoted word arrays
      var_ref = ast.xpath(%q{//command[ident/@value='depends']/
        descendant::var_ref/ident})
      unless var_ref.empty?
        deps += ast.xpath(%Q{//block_var/params/ident#{var_ref.first['value']}/
          ancestor::method_add_block/call/descendant::tstring_content})
      end
      deps.map{|dep| dep['value']}
    end

    # Create a match for a specified file. Use this if the presence of the file
    # triggers the warning rather than content.
    #
    # @param [String] file The filename to create a match for
    # @return [Hash] Hash with the match details
    # @see FoodCritic::Api#match
    def file_match(file)
      raise ArgumentError, "Filename cannot be nil" if file.nil?
      {:filename => file, :matched => file, :line => 1, :column => 1}
    end

    # Find Chef resources of the specified type.
    # TODO: Include blockless resources
    #
    # @param [Nokogiri::XML::Node] ast The AST of the cookbook recipe to check
    # @param [Hash] options The find options
    # @option [Symbol] :type The type of resource to look for (or :any for all
    #   resources)
    # @return [Array] AST nodes of Chef resources.
    def find_resources(ast, options = {})
      options = {:type => :any}.merge!(options)
      return [] unless ast.respond_to?(:xpath)
      scope_type = ''
      scope_type = "[@value='#{options[:type]}']" unless options[:type] == :any
      ast.xpath("//method_add_block[command/ident#{scope_type}]")
    end

    # Retrieve the recipes that are included within the given recipe AST.
    #
    # @param [Nokogiri::XML::Node] ast The recipe AST
    # @return [Hash] include_recipe nodes keyed by included recipe name
    def included_recipes(ast)
      raise_unless_xpath!(ast)
      # we only support literal strings, ignoring sub-expressions
      included = ast.xpath(%q{//command[ident/@value = 'include_recipe' and
        count(descendant::string_embexpr) = 0]/descendant::tstring_content})
      included.inject(Hash.new([])){|h, i| h[i['value']] += [i]; h}
    end

    # XPath custom function
    class AttFilter
      def is_att_type(value)
        return [] unless value.respond_to?(:select)
        value.select{|n| %w{node default override set normal}.include?(n.to_s)}
      end
    end

    # Searches performed by the specified recipe that are literal strings.
    # Searches with a query formed from a subexpression will be ignored.
    #
    # @param [Nokogiri::XML::Node] ast The AST of the cookbook recipe to check
    # @return [Array] The matching nodes
    def literal_searches(ast)
      return [] unless ast.respond_to?(:xpath)
      ast.xpath("//method_add_arg[fcall/ident/@value = 'search' and
        count(descendant::string_embexpr) = 0]/descendant::tstring_content")
    end

    # Create a match from the specified node.
    #
    # @param [Nokogiri::XML::Node] node The node to create a match for
    # @return [Hash] Hash with the matched node name and position with the
    #   recipe
    def match(node)
      raise_unless_xpath!(node)
      pos = node.xpath('descendant::pos').first
      return nil if pos.nil?
      {:matched => node.respond_to?(:name) ? node.name : '',
       :line => pos['line'].to_i, :column => pos['column'].to_i}
    end

    # Does the provided string look like an Operating System command? This is a
    # rough heuristic to be taken with a pinch of salt.
    #
    # @param [String] str The string to check
    # @return [Boolean] True if this string might be an OS command
    def os_command?(str)
      str.start_with?('grep ', 'which ') or # common commands
      str.include?('|') or                  # a pipe, could be alternation
      str.match(/^[\w]+$/) or               # command name only
      str.match(/ --?[a-z]/i)               # command-line flag
    end

    # Read the AST for the given Ruby source file
    #
    # @param [String] file The file to read
    # @return [Nokogiri::XML::Node] The recipe AST
    def read_ast(file)
      build_xml(Ripper::SexpBuilder.new(File.read(file)).parse)
    end

    # Retrieve a single-valued attribute from the specified resource.
    #
    # @param [Nokogiri::XML::Node] resource The resource AST to lookup the
    #   attribute under
    # @param [String] name The attribute name
    # @return [String] The attribute value for the specified attribute
    def resource_attribute(resource, name)
      raise ArgumentError, "Attribute name cannot be empty" if name.empty?
      resource_attributes(resource)[name.to_s]
    end

    # Retrieve all attributes from the specified resource.
    #
    # @param [Nokogiri::XML::Node] resource The resource AST
    # @return [Hash] The resource attributes
    def resource_attributes(resource)
      atts = {}
      name = resource_name(resource)
      atts[:name] = name unless name.empty?
      resource.xpath('do_block/descendant::command
                     [count(ancestor::do_block) = 1]').each do |att|
        if att.xpath('descendant::symbol').empty?
          att_value = att.xpath('string(descendant::tstring_content/@value)')
        else
          att_value =
            att.xpath('string(descendant::symbol/ident/@value)').to_sym
        end
        atts[att.xpath('string(ident/@value)')] = att_value
      end
      atts
    end

    # Retrieve the attributes as a hash for all resources of a given type.
    #
    # @param [Nokogiri::XML::Node] ast The recipe AST
    # @return [Hash] Resources keyed by type, with an array for each
    def resource_attributes_by_type(ast)
      result = {}
      resources_by_type(ast).each do |type,resources|
        result[type] = resources.map{|resource| resource_attributes(resource)}
      end
      result
    end

    # Retrieve the name attribute associated with the specified resource.
    #
    # @param [Nokogiri::XML::Node] resource The resource AST to lookup the name
    #   attribute under
    # @return [String] The name attribute value
    def resource_name(resource)
      raise_unless_xpath!(resource)
      resource.xpath('string(command//tstring_content/@value)')
    end

    # Retrieve all resources of a given type
    #
    # @param [Nokogiri::XML::Node] ast The recipe AST
    # @return [Hash] The matching resources
    def resources_by_type(ast)
      raise_unless_xpath!(ast)
      result = Hash.new{|hash, key| hash[key] = Array.new}
      find_resources(ast).each do |resource|
        result[resource_type(resource)] << resource
      end
      result
    end

    # Return the type, e.g. 'package' for a given resource
    #
    # @param [Nokogiri::XML::Node] resource The resource AST
    # @return [String] The type of resource
    def resource_type(resource)
      raise_unless_xpath!(resource)
      type = resource.xpath('string(command/ident/@value)')
      if type.empty?
        raise ArgumentError, "Provided AST node is not a resource"
      end
      type
    end

    # Does the provided string look like ruby code?
    #
    # @param [String] str The string to check for rubiness
    # @return [Boolean] True if this string could be syntactically valid Ruby
    def ruby_code?(str)
      str = str.to_s
      return false if str.empty?
      checker = FoodCritic::ErrorChecker.new(str)
      checker.parse
      ! checker.error?
    end

    # Searches performed by the specified recipe.
    #
    # @param [Nokogiri::XML::Node] ast The AST of the cookbook recipe to check.
    # @return [Array] The AST nodes in the recipe where searches are performed
    def searches(ast)
      return [] unless ast.respond_to?(:xpath)
      ast.xpath("//fcall/ident[@value = 'search']")
    end

    # The list of standard cookbook sub-directories.
    #
    # @return [Array] The standard list of directories.
    def standard_cookbook_subdirs
      %w{attributes definitions files libraries providers recipes resources
         templates}
    end

    private

    # Recurse the nested arrays provided by Ripper to create a tree we can more
    # easily apply expressions to.
    #
    # @param [Array] node The AST
    # @param [Nokogiri::XML::Document] doc The document being constructed
    # @param [Nokogiri::XML::Node] xml_node The current node
    # @return [Nokogiri::XML::Node] The XML representation
    def build_xml(node, doc = nil, xml_node=nil)
      if doc.nil?
        doc = Nokogiri::XML('<opt></opt>')
        xml_node = doc.root
      end
      if node.respond_to?(:each)
        node.drop(1).each do |child|
          if position_node?(child)
            pos = Nokogiri::XML::Node.new("pos", doc)
            pos['line'] = child.first.to_s
            pos['column'] = child[1].to_s
            xml_node.add_child(pos)
          else
            if child.respond_to?(:first)
              n = Nokogiri::XML::Node.new(
                child.first.to_s.gsub(/[^a-z_]/, ''), doc)
              xml_node.add_child(build_xml(child, doc, n))
            else
              xml_node['value'] = child.to_s unless child.nil?
            end
          end
        end
      end
      xml_node
    end

    # If the provided node is the line / column information.
    #
    # @param [Nokogiri::XML::Node] node A node within the AST
    # @return [Boolean] True if this node holds the position data
    def position_node?(node)
      node.respond_to?(:length) and node.length == 2 and
        node.respond_to?(:all?) and node.all?{|child| child.respond_to?(:to_i)}
    end

    def raise_unless_xpath!(ast)
      unless ast.respond_to?(:xpath)
        raise ArgumentError, "AST must support #xpath"
      end
    end

    def standard_attribute_access(ast, options)
      type = options[:type] == :string ? 'tstring_content' : options[:type]
      expr = '//*[self::aref_field or self::aref]'
      expr += '[is_att_type(descendant::ident'
      expr += '[not(ancestor::aref/call)]' if options[:ignore_calls]
      expr += "/@value)]/descendant::#{type}"
      if type == :symbol
        expr += "[count(ancestor::method_add_arg[position() = 1]/fcall) = 0]"
      end
      ast.xpath(expr, AttFilter.new).sort
    end

    def vivified_attribute_access(ast)
      calls = ast.xpath(%q{//*[self::call or self::field]
        [is_att_type(vcall/ident/@value) or
        is_att_type(var_ref/ident/@value)][@value='.']}, AttFilter.new)
      calls.select do |call|
        call.xpath("aref/args_add_block").size == 0 and
          (call.xpath("descendant::ident").size > 1 and
            ! chef_dsl_methods.include?(call.xpath("ident/@value").to_s.to_sym))
      end.sort
    end

  end

end
