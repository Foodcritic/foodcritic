require 'nokogiri'

module FoodCritic

  # Helper methods that form part of the Rules DSL.
  module Api

    include FoodCritic::AST
    include FoodCritic::XML

    include FoodCritic::Chef
    include FoodCritic::Notifications

    # Find attribute access by type.
    def attribute_access(ast, options = {})
      options = {:type => :any, :ignore_calls => false}.merge!(options)
      return [] unless ast.respond_to?(:xpath)

      # TODO: This rejects `:any` which is wrong
      unless [:string, :symbol, :vivified].include?(options[:type])
        raise ArgumentError, "Node type not recognised"
      end

      if options[:type] == :vivified
        vivified_attribute_access(ast, options[:cookbook_dir])
      else
        standard_attribute_access(ast, options)
      end
    end

    # Does the specified recipe check for Chef Solo?
    def checks_for_chef_solo?(ast)
      raise_unless_xpath!(ast)

      # TODO: This expression is too loose, but also will fail to match other
      # types of conditionals.
      ! ast.xpath(%q{//if/*[self::aref or self::call][count(descendant::const[@value = 'Chef' or
          @value = 'Config']) = 2
          and
            (   count(descendant::ident[@value='solo']) > 0
            or  count(descendant::tstring_content[@value='solo']) > 0
            )
          ]}).empty?
    end

    # Is the [chef-solo-search library](https://github.com/edelight/chef-solo-search)
    # available?
    def chef_solo_search_supported?(recipe_path)
      return false if recipe_path.nil? || ! File.exists?(recipe_path)

      # Look for the chef-solo-search library.
      #
      # TODO: This will not work if the cookbook that contains the library
      # is not under the same `cookbook_path` as the cookbook being checked.
      cbk_tree_path = Pathname.new(File.join(recipe_path, '../../..'))
      search_libs = Dir[File.join(cbk_tree_path.realpath,
        '*/libraries/search.rb')]

      # True if any of the candidate library files match the signature:
      #
      #     class Chef
      #       def search
      search_libs.any? do |lib|
        ! read_ast(lib).xpath(%q{//class[count(descendant::const[@value='Chef']
          ) = 1]/descendant::def/ident[@value='search']}).empty?
      end
    end

    # The name of the cookbook containing the specified file.
    def cookbook_name(file)
      raise ArgumentError, 'File cannot be nil or empty' if file.to_s.empty?

      until (file.split(File::SEPARATOR) & standard_cookbook_subdirs).empty? do
        file = File.absolute_path(File.dirname(file.to_s))
      end
      file = File.dirname(file) unless File.extname(file).empty?
      # We now have the name of the directory that contains the cookbook.

      # We also need to consult the metadata in case the cookbook name has been
      # overridden there. This supports only string literals.
      md_path = File.join(file, 'metadata.rb')
      if File.exists?(md_path)
        name = read_ast(md_path).xpath("//stmts_add/
          command[ident/@value='name']/descendant::tstring_content/@value").to_s
        return name unless name.empty?
      end
      File.basename(file)
    end

    # The dependencies declared in cookbook metadata.
    def declared_dependencies(ast)
      raise_unless_xpath!(ast)

      # String literals.
      #
      #     depends 'foo'
      deps = ast.xpath(%q{//command[ident/@value='depends']/
        descendant::args_add/descendant::tstring_content[1]})

      # Quoted word arrays are also common.
      #
      #     %w{foo bar baz}.each do |cbk|
      #       depends cbk
      #     end
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
    def file_match(file)
      raise ArgumentError, "Filename cannot be nil" if file.nil?
      {:filename => file, :matched => file, :line => 1, :column => 1}
    end

    # Find Chef resources of the specified type.
    # TODO: Include blockless resources
    #
    # These are equivalent:
    #
    #     find_resources(ast)
    #     find_resources(ast, :type => :any)
    #
    # Restrict to a specific type of resource:
    #
    #     find_resources(ast, :type => :service)
    #
    def find_resources(ast, options = {})
      options = {:type => :any}.merge!(options)
      return [] unless ast.respond_to?(:xpath)
      scope_type = ''
      scope_type = "[@value='#{options[:type]}']" unless options[:type] == :any

      # TODO: Include nested resources (provider actions)
      no_actions = "[command/ident/@value != 'action']"
      ast.xpath("//method_add_block[command/ident#{scope_type}]#{no_actions}")
    end

    # Helper to return a comparable version for a string.
    def gem_version(version)
      Gem::Version.create(version)
    end

    # Retrieve the recipes that are included within the given recipe AST.
    #
    # These two usages are equivalent:
    #
    #     included_recipes(ast)
    #     included_recipes(ast, :with_partial_names => true)
    #
    def included_recipes(ast, options = {:with_partial_names => true})
      raise_unless_xpath!(ast)

      filter = ['[count(descendant::args_add) = 1]']

      # If `:with_partial_names` is false then we won't include the string
      # literal portions of any string that has an embedded expression.
      unless options[:with_partial_names]
        filter << '[count(descendant::string_embexpr) = 0]'
      end

      included = ast.xpath(%Q{//command[ident/@value = 'include_recipe']#{filter.join}
        [descendant::args_add/string_literal]/descendant::tstring_content})

      # Hash keyed by recipe name with matched nodes.
      included.inject(Hash.new([])){|h, i| h[i['value']] += [i]; h}
    end

    # Searches performed by the specified recipe that are literal strings.
    # Searches with a query formed from a subexpression will be ignored.
    def literal_searches(ast)
      return [] unless ast.respond_to?(:xpath)
      ast.xpath("//method_add_arg[fcall/ident/@value = 'search' and
        count(descendant::string_embexpr) = 0]/descendant::tstring_content")
    end

    # Create a match from the specified node.
    def match(node)
      raise_unless_xpath!(node)
      pos = node.xpath('descendant::pos').first
      return nil if pos.nil?
      {:matched => node.respond_to?(:name) ? node.name : '',
       :line => pos['line'].to_i, :column => pos['column'].to_i}
    end

    # Does the provided string look like an Operating System command? This is a
    # rough heuristic to be taken with a pinch of salt.
    def os_command?(str)
      str.start_with?('grep ', 'net ', 'which ') or # common commands
      str.include?('|') or     # a pipe, could be alternation
      str.include?('/') or     # file path delimiter
      str.match(/^[\w]+$/) or  # command name only
      str.match(/ --?[a-z]/i)  # command-line flag
    end

    # Read the AST for the given Ruby source file
    def read_ast(file)
      source = if file.to_s.end_with? '.erb'
        Template::ExpressionExtractor.new.extract(
          File.read(file)).map{|e| e[:code]}.join("\n")
      else
        File.read(file)
      end
      build_xml(Ripper::SexpBuilder.new(source).parse)
    end

    # Retrieve a single-valued attribute from the specified resource.
    def resource_attribute(resource, name)
      raise ArgumentError, "Attribute name cannot be empty" if name.empty?
      resource_attributes(resource)[name.to_s]
    end

    # Retrieve all attributes from the specified resource.
    def resource_attributes(resource)
      atts = {}
      name = resource_name(resource)
      atts[:name] = name unless name.empty?

      # The ancestor check here ensures that nested blocks are not returned.
      # For example a method call within a `ruby_block` would otherwise be
      # returned as an attribute.
      #
      # TODO: This may need to be revisted in light of recent changes to the
      # application cookbook which is popularising nested blocks.
      resource.xpath('do_block/descendant::command
                     [count(ancestor::do_block) = 1]').each do |att|

        # Extract the attribute value, the paths here differ by type.
        att_value =
          if ! att.xpath('args_add_block[count(descendant::args_add)>1]').empty?
            att.xpath('args_add_block').first
          elsif ! att.xpath('args_add_block/args_add/
            var_ref/kw[@value="true" or @value="false"]').empty?
            att.xpath('string(args_add_block/args_add/
              var_ref/kw/@value)') == 'true'
          elsif att.xpath('descendant::symbol').empty?
            att.xpath('string(descendant::tstring_content/@value)')
          else
            att.xpath('string(descendant::symbol/ident/@value)').to_sym
          end
        atts[att.xpath('string(ident/@value)')] = att_value
      end

      # The attribute value may alternatively be a block, such as the meta
      # conditionals `not_if` and `only_if`.
      resource.xpath("do_block/descendant::method_add_block[
        count(ancestor::do_block) = 1][brace_block | do_block]").each do |batt|
          att_name = batt.xpath('string(method_add_arg/fcall/ident/@value)')
          if att_name and ! att_name.empty? and batt.children.length > 1
            atts[att_name] = batt.children[1]
          end
      end
      atts
    end

    # Resources keyed by type, with an array of matching nodes for each.
    def resource_attributes_by_type(ast)
      result = {}
      resources_by_type(ast).each do |type,resources|
        result[type] = resources.map{|resource| resource_attributes(resource)}
      end
      result
    end

    # Retrieve the name attribute associated with the specified resource.
    def resource_name(resource)
      raise_unless_xpath!(resource)
      resource.xpath('string(command//tstring_content/@value)')
    end

    # Resources in an AST, keyed by type.
    def resources_by_type(ast)
      raise_unless_xpath!(ast)
      result = Hash.new{|hash, key| hash[key] = Array.new}
      find_resources(ast).each do |resource|
        result[resource_type(resource)] << resource
      end
      result
    end

    # Return the type, e.g. 'package' for a given resource
    def resource_type(resource)
      raise_unless_xpath!(resource)
      type = resource.xpath('string(command/ident/@value)')
      if type.empty?
        raise ArgumentError, "Provided AST node is not a resource"
      end
      type
    end

    # Does the provided string look like ruby code?
    def ruby_code?(str)
      str = str.to_s
      return false if str.empty?

      checker = FoodCritic::ErrorChecker.new(str)
      checker.parse
      ! checker.error?
    end

    # Searches performed by the provided AST.
    def searches(ast)
      return [] unless ast.respond_to?(:xpath)
      ast.xpath("//fcall/ident[@value = 'search']")
    end

    # The list of standard cookbook sub-directories.
    def standard_cookbook_subdirs
      %w{attributes definitions files libraries providers recipes resources
         templates}
    end

    # Template filename
    def template_file(resource)
      resource_attributes(resource)['source']
    end

    # Templates in the current cookbook
    def template_paths(recipe_path)
      Dir[Pathname.new(recipe_path).dirname.dirname + 'templates' + '**/*.erb']
    end

    private

    # Recurse the nested arrays provided by Ripper to create a tree we can more
    # easily apply expressions to.
    def build_xml(node, doc = nil, xml_node=nil)
      doc, xml_node = xml_document(doc, xml_node)

      if node.respond_to?(:each)
        # First child is the node name
        node.drop(1).each do |child|
          if position_node?(child)
            xml_position_node(doc, xml_node, child)
          else
            if ast_node_has_children?(child)
              # The AST structure is different for hashes so we have to treat
              # them separately.
              if ast_hash_node?(child)
                xml_hash_node(doc, xml_node, child)
              else
                xml_array_node(doc, xml_node, child)
              end
            else
              xml_node['value'] = child.to_s unless child.nil?
            end
          end
        end
      end
      xml_node
    end

    def node_method?(meth, cookbook_dir)
      chef_dsl_methods.include?(meth) || patched_node_method?(meth, cookbook_dir)
    end

    def patched_node_method?(meth, cookbook_dir)
      return false if cookbook_dir.nil? || ! Dir.exists?(cookbook_dir)

      # TODO: Modify this to work with multiple cookbook paths
      cbk_tree_path = Pathname.new(File.join(cookbook_dir, '..'))
      libs = Dir[File.join(cbk_tree_path.realpath, '*/libraries/*.rb')]

      libs.any? do |lib|
        ! read_ast(lib).xpath(%Q{//class[count(descendant::const[@value='Chef'])
          > 0][count(descendant::const[@value='Node']) > 0]/descendant::def/
          ident[@value='#{meth.to_s}']}).empty?
      end
    end

    def raise_unless_xpath!(ast)
      unless ast.respond_to?(:xpath)
        raise ArgumentError, "AST must support #xpath"
      end
    end

    # XPath custom function
    class AttFilter
      def is_att_type(value)
        return [] unless value.respond_to?(:select)
        value.select{|n| %w{node default override set normal}.include?(n.to_s)}
      end
    end

    def standard_attribute_access(ast, options)
      type = options[:type] == :string ? 'tstring_content' : options[:type]
      expr = '//*[self::aref_field or self::aref]'
      expr += '[is_att_type(descendant::ident'
      expr += '[not(ancestor::aref/call)]' if options[:ignore_calls]
      expr += "/@value)]/descendant::#{type}"
      expr += "[ident/@value != 'node']" if type == :symbol
      ast.xpath(expr, AttFilter.new).sort
    end

    def vivified_attribute_access(ast, cookbook_dir)
      calls = ast.xpath(%q{//*[self::call or self::field]
        [is_att_type(vcall/ident/@value) or is_att_type(var_ref/ident/@value)]
        [@value='.'][count(following-sibling::arg_paren) = 0]}, AttFilter.new)
      calls.select do |call|
        call.xpath("aref/args_add_block").size == 0 and
          (call.xpath("descendant::ident").size > 1 and
            ! node_method?(call.xpath("ident/@value").to_s.to_sym, cookbook_dir))
      end.sort
    end

  end

end
