require 'nokogiri'
require 'rufus-lru'

module FoodCritic
  # Helper methods that form part of the Rules DSL.
  module Api
    include FoodCritic::AST
    include FoodCritic::XML

    include FoodCritic::Chef
    include FoodCritic::Notifications

    class RecursedTooFarError < StandardError; end

    # Find attribute access by type.
    def attribute_access(ast, options = {})
      options = { type: :any, ignore_calls: false }.merge!(options)
      return [] unless ast.respond_to?(:xpath)

      unless [:any, :string, :symbol, :vivified].include?(options[:type])
        fail ArgumentError, 'Node type not recognised'
      end

      case options[:type]
      when :any then
          vivified_attribute_access(ast, options) +
            standard_attribute_access(ast, options)
      when :vivified then
          vivified_attribute_access(ast, options)
      else
          standard_attribute_access(ast, options)
      end
    end

    # Does the specified recipe check for Chef Solo?
    def checks_for_chef_solo?(ast)
      raise_unless_xpath!(ast)
      # TODO: This expression is too loose, but also will fail to match other
      # types of conditionals.
      (!ast.xpath(%q{//*[self::if or self::ifop or self::unless]/
        *[self::aref or child::aref or self::call]
        [count(descendant::const[@value = 'Chef' or @value = 'Config']) = 2
          and
            (   count(descendant::ident[@value='solo']) > 0
            or  count(descendant::tstring_content[@value='solo']) > 0
            )
          ]}).empty?) ||
      ast.xpath('//if_mod[return][aref/descendant::ident/@value="solo"]/aref/
        const_path_ref/descendant::const').map do |c|
        c['value']
      end == %w(Chef Config)
    end

    # Is the
    # [chef-solo-search library](https://github.com/edelight/chef-solo-search)
    # available?
    def chef_solo_search_supported?(recipe_path)
      return false if recipe_path.nil? || !File.exist?(recipe_path)

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
        !read_ast(lib).xpath(%q{//class[count(descendant::const[@value='Chef']
          ) = 1]/descendant::def/ident[@value='search']}).empty?
      end
    end

    # The name of the cookbook containing the specified file.
    def cookbook_name(file)
      fail ArgumentError, 'File cannot be nil or empty' if file.to_s.empty?

      until (file.split(File::SEPARATOR) & standard_cookbook_subdirs).empty? do
        file = File.absolute_path(File.dirname(file.to_s))
      end
      file = File.dirname(file) unless File.extname(file).empty?
      # We now have the name of the directory that contains the cookbook.

      # We also need to consult the metadata in case the cookbook name has been
      # overridden there. This supports only string literals.
      md_path = File.join(file, 'metadata.rb')
      if File.exist?(md_path)
        name = read_ast(md_path).xpath("//stmts_add/
          command[ident/@value='name']/
          descendant::tstring_content/@value").to_s
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
      deps = deps.to_a +
        word_list_values(ast, "//command[ident/@value='depends']")
      deps.uniq.map { |dep| dep['value'].strip }
    end

    # The key / value pair in an environment or role ruby file
    def field(ast, field_name)
      if field_name.nil? || field_name.to_s.empty?
        fail ArgumentError, 'Field name cannot be nil or empty'
      end
      ast.xpath("//command[ident/@value='#{field_name}']")
    end

    # The value for a specific key in an environment or role ruby file
    def field_value(ast, field_name)
      field(ast, field_name).xpath('args_add_block/descendant::tstring_content
        [count(ancestor::args_add) = 1][count(ancestor::string_add) = 1]
        /@value').map { |a| a.to_s }.last
    end

    # Create a match for a specified file. Use this if the presence of the file
    # triggers the warning rather than content.
    def file_match(file)
      fail ArgumentError, 'Filename cannot be nil' if file.nil?
      { filename: file, matched: file, line: 1, column: 1 }
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
      options = { type: :any }.merge!(options)
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
    def included_recipes(ast, options = { with_partial_names: true })
      raise_unless_xpath!(ast)

      filter = ['[count(descendant::args_add) = 1]']

      # If `:with_partial_names` is false then we won't include the string
      # literal portions of any string that has an embedded expression.
      unless options[:with_partial_names]
        filter << '[count(descendant::string_embexpr) = 0]'
      end

      string_desc = '[descendant::args_add/string_literal]/
        descendant::tstring_content'
      included = ast.xpath([
        "//command[ident/@value = 'include_recipe']",
        "//fcall[ident/@value = 'include_recipe']/
         following-sibling::arg_paren",
      ].map do |recipe_include|
        recipe_include + filter.join + string_desc
      end.join(' | '))

      # Hash keyed by recipe name with matched nodes.
      included.inject(Hash.new([])) { |h, i| h[i['value']] += [i]; h }
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
      { matched: node.respond_to?(:name) ? node.name : '',
       line: pos['line'].to_i, column: pos['column'].to_i }
    end

    # Read the AST for the given Ruby source file
    def read_ast(file)
      @ast_cache ||= Rufus::Lru::Hash.new(5)
      if @ast_cache.include?(file)
        @ast_cache[file]
      else
        @ast_cache[file] = uncached_read_ast(file)
      end
    end

    # Retrieve a single-valued attribute from the specified resource.
    def resource_attribute(resource, name)
      fail ArgumentError, 'Attribute name cannot be empty' if name.empty?
      resource_attributes(resource)[name.to_s]
    end

    # Retrieve all attributes from the specified resource.
    def resource_attributes(resource, options = {})
      atts = {}
      name = resource_name(resource, options)
      atts[:name] = name unless name.empty?
      atts.merge!(normal_attributes(resource, options))
      atts.merge!(block_attributes(resource))
      atts
    end

    # Resources keyed by type, with an array of matching nodes for each.
    def resource_attributes_by_type(ast)
      result = {}
      resources_by_type(ast).each do |type, resources|
        result[type] = resources.map do |resource|
          resource_attributes(resource)
        end
      end
      result
    end

    # Retrieve the name attribute associated with the specified resource.
    def resource_name(resource, options = {})
      raise_unless_xpath!(resource)
      options = { return_expressions: false }.merge(options)
      if options[:return_expressions]
        name = resource.xpath('command/args_add_block')
        if name.xpath('descendant::string_add').size == 1 &&
          name.xpath('descendant::string_literal').size == 1 &&
          name.xpath(
            'descendant::*[self::call or self::string_embexpr]').empty?
          name.xpath('descendant::tstring_content/@value').to_s
        else
          name
        end
      else
        # Preserve existing behaviour
        resource.xpath('string(command//tstring_content/@value)')
      end
    end

    # Resources in an AST, keyed by type.
    def resources_by_type(ast)
      raise_unless_xpath!(ast)
      result = Hash.new { |hash, key| hash[key] = Array.new }
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
        fail ArgumentError, 'Provided AST node is not a resource'
      end
      type
    end

    # Does the provided string look like ruby code?
    def ruby_code?(str)
      str = str.to_s
      return false if str.empty?

      checker = FoodCritic::ErrorChecker.new(str)
      checker.parse
      !checker.error?
    end

    # Searches performed by the provided AST.
    def searches(ast)
      return [] unless ast.respond_to?(:xpath)
      ast.xpath("//fcall/ident[@value = 'search']")
    end

    # The list of standard cookbook sub-directories.
    def standard_cookbook_subdirs
      %w(attributes definitions files libraries providers recipes resources
         templates)
    end

    # Platforms declared as supported in cookbook metadata
    def supported_platforms(ast)
      platforms = ast.xpath('//command[ident/@value="supports"]/
        descendant::*[self::string_literal or self::symbol_literal]
        [position() = 1]
        [self::symbol_literal or count(descendant::string_add) = 1]/
        descendant::*[self::tstring_content | self::ident]')
      platforms = platforms.to_a +
        word_list_values(ast, "//command[ident/@value='supports']")
      platforms.map do |platform|
        versions = platform.xpath('ancestor::args_add[position() > 1]/
	  string_literal/descendant::tstring_content/@value').map { |v| v.to_s }
        { platform: platform['value'], versions: versions }
      end.sort { |a, b| a[:platform] <=> b[:platform] }
    end

    # Template filename
    def template_file(resource)
      if resource['source']
        resource['source']
      elsif resource[:name]
        if resource[:name].respond_to?(:xpath)
          resource[:name]
        else
          "#{File.basename(resource[:name])}.erb"
        end
      end
    end

    def templates_included(all_templates, template_path, depth = 1)
      fail RecursedTooFarError.new(template_path) if depth > 10
      partials = read_ast(template_path).xpath('//*[self::command or
        child::fcall][descendant::ident/@value="render"]//args_add/
        string_literal//tstring_content/@value').map { |p| p.to_s }
      Array(template_path) + partials.map do |included_partial|
        partial_path = Array(all_templates).find do |path|
          (Pathname.new(template_path).dirname + included_partial).to_s == path
        end
        if partial_path
          Array(partial_path) +
            templates_included(all_templates, partial_path, depth + 1)
        end
      end.flatten.uniq.compact
    end

    # Templates in the current cookbook
    def template_paths(recipe_path)
      Dir.glob(Pathname.new(recipe_path).dirname.dirname + 'templates' +
        '**/*', File::FNM_DOTMATCH).select do |path|
        File.file?(path)
      end.reject do |path|
        File.basename(path) == '.DS_Store' || File.extname(path) == '.swp'
      end
    end

    private

    def block_attributes(resource)
      # The attribute value may alternatively be a block, such as the meta
      # conditionals `not_if` and `only_if`.
      atts = {}
      resource.xpath("do_block/descendant::method_add_block[
        count(ancestor::do_block) = 1][brace_block | do_block]").each do |batt|
        att_name = batt.xpath('string(method_add_arg/fcall/ident/@value)')
        if att_name && !att_name.empty? && batt.children.length > 1
          atts[att_name] = batt.children[1]
        end
      end
      atts
    end

    def block_depth(resource)
      resource.path.split('/').group_by { |e|e }['method_add_block'].size
    end

    # Recurse the nested arrays provided by Ripper to create a tree we can more
    # easily apply expressions to.
    def build_xml(node, doc = nil, xml_node = nil)
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

    def extract_attribute_value(att, options = {})
      if !att.xpath('args_add_block[count(descendant::args_add)>1]').empty?
        att.xpath('args_add_block').first
      elsif !att.xpath('args_add_block/args_add/
        var_ref/kw[@value="true" or @value="false"]').empty?
        att.xpath('string(args_add_block/args_add/
          var_ref/kw/@value)') == 'true'
      elsif !att.xpath('descendant::assoc_new').empty?
        att.xpath('descendant::assoc_new')
      elsif !att.xpath('descendant::int').empty?
        att.xpath('descendant::int/@value').to_s
      elsif att.xpath('descendant::symbol').empty?
        if options[:return_expressions] &&
           (att.xpath('descendant::string_add').size != 1 ||
            att.xpath('descendant::*[self::call or
              self::string_embexpr]').any?)
          att
        else
          att.xpath('string(descendant::tstring_content/@value)')
        end
      else
        att.xpath('string(descendant::symbol/ident/@value)').to_sym
      end
    end

    def ignore_attributes_xpath(ignores)
      Array(ignores).map do |ignore|
        "[count(descendant::*[@value='#{ignore}']) = 0]"
      end.join
    end

    def node_method?(meth, cookbook_dir)
      chef_dsl_methods.include?(meth) ||
        patched_node_method?(meth, cookbook_dir)
    end

    def normal_attributes(resource, options = {})
      atts = {}
      resource.xpath('do_block/descendant::*[self::command or
        self::method_add_arg][count(ancestor::do_block) >= 1]').each do |att|
        blocks = att.xpath('ancestor::method_add_block/method_add_arg/fcall')
        next if blocks.any? { |a| block_depth(a) > block_depth(resource) }
        att_name = att.xpath('string(ident/@value |
          fcall/ident[@value="variables"]/@value)')
        unless att_name.empty?
          atts[att_name] = extract_attribute_value(att, options)
        end
      end
      atts
    end

    def patched_node_method?(meth, cookbook_dir)
      return false if cookbook_dir.nil? || !Dir.exists?(cookbook_dir)

      # TODO: Modify this to work with multiple cookbook paths
      cbk_tree_path = Pathname.new(File.join(cookbook_dir, '..'))
      libs = Dir[File.join(cbk_tree_path.realpath, '*/libraries/*.rb')]

      libs.any? do |lib|
        !read_ast(lib).xpath(%Q{//class[count(descendant::const[@value='Chef'])
          > 0][count(descendant::const[@value='Node']) > 0]/descendant::def/
          ident[@value='#{meth.to_s}']}).empty?
      end
    end

    def raise_unless_xpath!(ast)
      unless ast.respond_to?(:xpath)
        fail ArgumentError, 'AST must support #xpath'
      end
    end

    def uncached_read_ast(file)
      source = if file.to_s.split(File::SEPARATOR).include?('templates')
                 template_expressions_only(file)
               else
                 File.read(file)
               end
      build_xml(Ripper::SexpBuilder.new(source).parse)
    end

    # XPath custom function
    class AttFilter
      def is_att_type(value)
        return [] unless value.respond_to?(:select)
        value.select do |n|
          %w(
            automatic_attrs
            default
            default!
            default_unless
            force_default
            force_override
            node
            normal
            normal_unless
            override
            override!
            override_unless
            set
            set_unless
          ).include?(n.to_s)
        end
      end
    end

    def standard_attribute_access(ast, options)
      if options[:type] == :any
        [:string, :symbol].map do |type|
          standard_attribute_access(ast, options.merge(type: type))
        end.inject(:+)
      else
        type = if options[:type] == :string
                 'tstring_content'
               else
                 '*[self::symbol or self::dyna_symbol]'
               end
        expr = '//*[self::aref_field or self::aref][count(method_add_arg) = 0]'
        expr += '[count(is_att_type(descendant::var_ref/ident/@value)) =
          count(descendant::var_ref/ident/@value)]'
        expr += '[is_att_type(descendant::ident'
        expr += '[not(ancestor::aref/call)]' if options[:ignore_calls]
        expr += '/@value)]'
        expr += ignore_attributes_xpath(options[:ignore])
        expr += "/descendant::#{type}"
        if options[:type] == :string
          expr += '[count(ancestor::dyna_symbol) = 0]'
        end
        ast.xpath(expr, AttFilter.new).sort
      end
    end

    def template_expressions_only(file)
      exprs = Template::ExpressionExtractor.new.extract(File.read(file))
      lines = Array.new(exprs.map { |e| e[:line] }.max || 0, '')
      exprs.each do |e|
        lines[e[:line] - 1] += ';' unless lines[e[:line] - 1].empty?
        lines[e[:line] - 1] += e[:code]
      end
      lines.join("\n")
    end

    def vivified_attribute_access(ast, options = {})
      calls = ast.xpath(%Q{//*[self::call or self::field]
        [is_att_type(vcall/ident/@value) or is_att_type(var_ref/ident/@value)]
        #{ignore_attributes_xpath(options[:ignore])}
        [@value='.'][count(following-sibling::arg_paren) = 0]}, AttFilter.new)
      calls.select do |call|
        call.xpath('aref/args_add_block').size == 0 &&
          (call.xpath('descendant::ident').size > 1 &&
            !node_method?(call.xpath('ident/@value').to_s.to_sym,
                          options[:cookbook_dir]))
      end.sort
    end

    def word_list_values(ast, xpath)
      var_ref = ast.xpath("#{xpath}/descendant::var_ref/ident")
      if var_ref.empty?
        []
      else
        ast.xpath(%Q(descendant::block_var/params/
          ident#{var_ref.first['value']}/ancestor::method_add_block/call/
          descendant::tstring_content))
      end
    end
  end
end
