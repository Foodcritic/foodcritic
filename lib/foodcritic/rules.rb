# This file contains all of the rules that ship with foodcritic.
#
# * Foodcritic rules perform static code analysis - rather than the cookbook
#   code being loaded by the interpreter it is parsed into a tree (AST) that is
#   then passed to each rule.
# * Rules can use a number of API functions that ship with foodcritic to make
#   sense of the parse tree.
# * Rules can also use XPath to query the AST. A rule can consist of a XPath
#   query only, as any nodes returned from a `recipe` block will be converted
#   into warnings.

rule "FC001",
     "Use strings in preference to symbols to access node attributes" do
  tags %w{style attributes}
  recipe do |ast|
    attribute_access(ast, type: :symbol)
  end
end

rule "FC002", "Avoid string interpolation where not required" do
  tags %w{style strings}
  recipe do |ast|
    ast.xpath(%q{//*[self::string_literal | self::assoc_new]/string_add[
      count(descendant::string_embexpr) = 1 and
      count(string_add) = 0]})
  end
end

# FC003 was yanked and the number should not be reused

rule "FC004", "Use a service resource to start and stop services" do
  tags %w{style services}
  recipe do |ast|
    find_resources(ast, type: "execute").find_all do |cmd|
      cmd_str = (resource_attribute(cmd, "command") || resource_name(cmd)).to_s
      (cmd_str.include?("/etc/init.d") || ["service ", "/sbin/service ",
       "start ", "stop ", "invoke-rc.d "].any? do |service_cmd|
         cmd_str.start_with?(service_cmd)
       end) && %w{start stop restart reload}.any? { |a| cmd_str.include?(a) }
    end
  end
end

rule "FC005", "Avoid repetition of resource declarations" do
  tags %w{style}
  recipe do |ast|
    resources = find_resources(ast).map do |res|
      resource_attributes(res).merge({ type: resource_type(res),
                                       ast: res })
    end.chunk do |res|
      res[:type] +
        res[:ast].xpath("ancestor::*[self::if | self::unless | self::elsif |
          self::else | self::when | self::method_add_block/call][position() = 1]/
          descendant::pos[position() = 1]").to_s +
        res[:ast].xpath("ancestor::method_add_block/command[
          ident/@value='action']/args_add_block/descendant::ident/@value").to_s
    end.reject { |res| res[1].size < 3 }
    resources.map do |cont_res|
      first_resource = cont_res[1][0][:ast]
      # we have contiguous resources of the same type, but do they share the
      # same attributes?
      sorted_atts = cont_res[1].map do |atts|
        atts.delete_if { |k| k == :ast }.to_a.sort do |x, y|
          x.first.to_s <=> y.first.to_s
        end
      end
      first_resource if sorted_atts.all? do |att|
        (att - sorted_atts.inject { |atts, a| atts & a }).length == 1
      end
    end.compact
  end
end

rule "FC006",
     "Mode should be quoted or fully specified when "\
     "setting file permissions" do
  tags %w{correctness files}
  recipe do |ast|
    ast.xpath(%q{//ident[@value='mode']/parent::command/
      descendant::int[string-length(@value) < 5
      and not(starts-with(@value, "0")
      and string-length(@value) = 4)][count(ancestor::aref) = 0]/
      ancestor::method_add_block})
  end
end

rule "FC007", "Ensure recipe dependencies are reflected "\
              "in cookbook metadata" do
  tags %w{correctness metadata}
  recipe do |ast, filename|
    metadata_path = Pathname.new(
      File.join(File.dirname(filename), "..", "metadata.rb")).cleanpath
    next unless File.exist? metadata_path
    actual_included = included_recipes(ast, with_partial_names: false)
    undeclared = actual_included.keys.map do |recipe|
      recipe.split("::").first
    end - [cookbook_name(filename)] -
      declared_dependencies(read_ast(metadata_path))
    actual_included.map do |recipe, include_stmts|
      if undeclared.include?(recipe) ||
          undeclared.any? { |u| recipe.start_with?("#{u}::") }
        include_stmts
      end
    end.flatten.compact
  end
end

rule "FC008", "Generated cookbook metadata needs updating" do
  tags %w{style metadata}
  metadata do |ast, filename|
    {
      "maintainer" => "YOUR_COMPANY_NAME",
      "maintainer_email" => "YOUR_EMAIL",
    }.map do |field, value|
      ast.xpath(%Q{//command[ident/@value='#{field}']/
                   descendant::tstring_content[@value='#{value}']})
    end
  end
end

# FC009 has been deprecated in favor of a Chefspec converge, which
# results in fewer false positives and works without updating chef metadata

rule "FC010", "Invalid search syntax" do
  tags %w{correctness search}
  recipe do |ast|
    # This only works for literal search strings
    literal_searches(ast).reject { |search| valid_query?(search["value"]) }
  end
end

rule "FC011", "Missing README in markdown format" do
  tags %w{style readme}
  cookbook do |filename|
    unless File.exist?(File.join(filename, "README.md"))
      [file_match(File.join(filename, "README.md"))]
    end
  end
end

rule "FC012", "Use Markdown for README rather than RDoc" do
  tags %w{style readme}
  cookbook do |filename|
    if File.exist?(File.join(filename, "README.rdoc"))
      [file_match(File.join(filename, "README.rdoc"))]
    end
  end
end

rule "FC013", "Use file_cache_path rather than hard-coding tmp paths" do
  tags %w{style files}
  recipe do |ast|
    find_resources(ast, type: "remote_file").find_all do |download|
      path = (resource_attribute(download, "path") ||
        resource_name(download)).to_s
      path.start_with?("/tmp/")
    end
  end
end

rule "FC014", "Consider extracting long ruby_block to library" do
  tags %w{style libraries}
  recipe do |ast|
    find_resources(ast, type: "ruby_block").find_all do |rb|
      lines = rb.xpath("descendant::fcall[ident/@value='block']/../../
        descendant::*[@line]/@line").map { |n| n.value.to_i }.sort
      (!lines.empty?) && (lines.last - lines.first) > 15
    end
  end
end

rule "FC015", "Consider converting definition to a Custom Resource" do
  tags %w{style definitions lwrp}
  cookbook do |dir|
    Dir[File.join(dir, "definitions", "*.rb")].reject do |entry|
      [".", ".."].include? entry
    end.map { |entry| file_match(entry) }
  end
end

rule "FC016", "LWRP does not declare a default action" do
  tags %w{correctness lwrp}
  resource do |ast, filename|
    unless ["//ident/@value='default_action'",
     "//def/bodystmt/descendant::assign/
      var_field/ivar/@value='@action'"].any? { |expr| ast.xpath(expr) }
      [file_match(filename)]
    end
  end
end

rule "FC017", "LWRP does not notify when updated" do
  tags %w{correctness lwrp}
  provider do |ast, filename|

    use_inline_resources = !ast.xpath('//*[self::vcall or self::var_ref]/ident
      [@value="use_inline_resources"]').empty?

    unless use_inline_resources
      actions = ast.xpath('//method_add_block/command[ident/@value="action"]/
        args_add_block/descendant::symbol/ident')

      actions.reject do |action|
        blk = action.xpath('ancestor::command[1]/
          following-sibling::*[self::do_block or self::brace_block]')
        empty = !blk.xpath("stmts_add/void_stmt").empty?
        converge_by = !blk.xpath('descendant::*[self::command or self::fcall]
          /ident[@value="converge_by"]').empty?

        updated_by_last_action = !blk.xpath('descendant::*[self::call or
          self::command_call]/*[self::vcall or self::var_ref/ident/
          @value="new_resource"]/../ident[@value="updated_by_last_action"]
        ').empty?

        empty || converge_by || updated_by_last_action
      end
    end

  end
end

rule "FC018", "LWRP uses deprecated notification syntax" do
  tags %w{style lwrp deprecated}
  provider do |ast|
    ast.xpath("//assign/var_field/ivar[@value='@updated']").map do |class_var|
      match(class_var)
    end + ast.xpath(%q{//assign/field/*[self::vcall or self::var_ref/ident/
                       @value='new_resource']/../ident[@value='updated']})
  end
end

rule "FC019", "Access node attributes in a consistent manner" do
  tags %w{style attributes}
  cookbook do |cookbook_dir|
    asts = {}; files = Dir["#{cookbook_dir}/*/*.rb"].reject do |file|
      relative_path = Pathname.new(file).relative_path_from(
        Pathname.new(cookbook_dir))
      relative_path.to_s.split(File::SEPARATOR).include?("spec")
    end.map do |file|
      { path: file, ast: read_ast(file) }
    end
    types = [:string, :symbol, :vivified].map do |type|
      {
        access_type: type, count: files.map do |file|
          attribute_access(file[:ast], type: type, ignore_calls: true,
                                       cookbook_dir: cookbook_dir, ignore: "run_state").tap do |ast|
            unless ast.empty?
              (asts[type] ||= []) << { ast: ast, path: file[:path] }
            end
          end.size
        end.inject(:+)
      }
    end.reject { |type| type[:count] == 0 }
    if asts.size > 1
      least_used = asts[types.min do |a, b|
        a[:count] <=> b[:count]
      end[:access_type]]
      least_used.map do |file|
        file[:ast].map do |ast|
          match(ast).merge(filename: file[:path])
        end.flatten
      end
    end
  end
end

rule "FC021", "Resource condition in provider may not behave as expected" do
  tags %w{correctness lwrp}
  provider do |ast|
    find_resources(ast).map do |resource|
      condition = resource.xpath(%q{//method_add_block/
        descendant::ident[@value='not_if' or @value='only_if']/
        ancestor::*[self::method_add_block or self::command][1][descendant::
        ident/@value='new_resource']/ancestor::stmts_add[2]/method_add_block/
        command[count(descendant::string_embexpr) = 0]})
      condition
    end.compact
  end
end

rule "FC022", "Resource condition within loop may not behave as expected" do
  tags %w{correctness}
  recipe do |ast|
    ast.xpath("//call[ident/@value='each']/../do_block[count(ancestor::
              method_add_block/method_add_arg/fcall/ident[@value='only_if' or
              @value = 'not_if']) = 0]").map do |lp|
      block_vars = lp.xpath("block_var/params/child::*").map do |n|
        n.name.sub(/^ident/, "")
      end + lp.xpath("block_var/params/child::*/descendant::ident").map do |v|
        v["value"]
      end
      find_resources(lp).map do |resource|
        # if any of the parameters to the block are used in a condition then we
        # have a match
        unless (block_vars &
          (resource.xpath(%q{descendant::ident[@value='not_if' or
          @value='only_if']/ancestor::*[self::method_add_block or
          self::command][1]/descendant::ident/@value}).map do |a|
            a.value
          end)).empty?
          c = resource.xpath("command[count(descendant::string_embexpr) = 0]")
          if resource.xpath("command/ident/@value").first.value == "define"
            next
          end
          resource unless c.empty? || block_vars.any? do |var|
            !resource.xpath(%Q{command/args_add_block/args_add/
              var_ref/ident[@value='#{var}']}).empty?
          end
        end
      end
    end.flatten.compact
  end
end

rule "FC023", "Prefer conditional attributes" do
  tags %w{style}
  recipe do |ast|
    ast.xpath(%q{//method_add_block[command/ident][count(descendant::ident
      [@value='only_if' or @value='not_if']) = 0]/ancestor::*[self::if or
      self::unless][count(descendant::method_add_block[command/ident]) = 1]
      [count(stmts_add/method_add_block/call) = 0]
      [count(stmts_add/stmts_add) = 0]
      [count(descendant::*[self::else or self::elsif]) = 0]})
  end
end

rule "FC024", "Consider adding platform equivalents" do
  tags %w{portability}
  RHEL = %w{amazon centos redhat scientific oracle}
  recipe do |ast, filename|
    next if Pathname.new(filename).basename.to_s == "metadata.rb"
    metadata_path = Pathname.new(
      File.join(File.dirname(filename), "..", "metadata.rb")).cleanpath
    md_platforms = if File.exist?(metadata_path)
                     supported_platforms(read_ast(
                       metadata_path)).map { |p| p[:platform] }
                   else
                     []
                   end
    md_platforms = RHEL if md_platforms.empty?

    ['//method_add_arg[fcall/ident/@value="platform?"]/
      arg_paren/args_add_block',
     "//when"].map do |expr|
      ast.xpath(expr).map do |whn|
        platforms = whn.xpath('args_add/
                               descendant::tstring_content').map do |p|
          p["value"]
        end.sort
        unless platforms.size == 1 || (md_platforms & platforms).empty?
          whn unless (platforms & RHEL).empty? ||
              ((md_platforms & RHEL) - (platforms & RHEL)).empty?
        end
      end.compact
    end.flatten
  end
end

rule "FC025", "Prefer chef_gem to compile-time gem install" do
  tags %w{style deprecated}
  recipe do |ast|
    gem_install = ast.xpath("//stmts_add/assign[method_add_block[command/ident/
      @value='gem_package'][do_block/stmts_add/command[ident/@value='action']
      [descendant::ident/@value='nothing']]]")
    gem_install.map do |install|
      gem_var = install.xpath("var_field/ident/@value")
      unless ast.xpath("//method_add_arg[call/
        var_ref/ident/@value='#{gem_var}']
        [arg_paren/descendant::ident/@value='install' or
         arg_paren/descendant::ident/@value='upgrade']").empty?
        gem_install
      end
    end
  end
end

rule "FC026", "Conditional execution block attribute contains only string" do
  tags %w{correctness}
  recipe do |ast|
    find_resources(ast).map { |r| resource_attributes(r) }.map do |resource|
      [resource["not_if"], resource["only_if"]]
    end.flatten.compact.select do |condition|
      condition.respond_to?(:xpath) &&
        !condition.xpath("descendant::string_literal").empty? &&
        !condition.xpath("stmts_add/string_literal").empty? &&
        condition.xpath('descendant::stmts_add[count(ancestor::
          string_literal) = 0]').size == 1
    end
  end
end

rule "FC027", "Resource sets internal attribute" do
  tags %w{correctness}
  recipe do |ast|
    find_resources(ast, type: :service).map do |service|
      service unless (resource_attributes(service).keys &
                        %w{enabled running}).empty?
    end.compact
  end
end

rule "FC028", "Incorrect #platform? usage" do
  tags %w{correctness}
  recipe do |ast|
    ast.xpath(%q{//*[self::call | self::command_call]
      [(var_ref|vcall)/ident/@value='node']
      [ident/@value="platform?"]})
  end
end

rule "FC029", "No leading cookbook name in recipe metadata" do
  tags %w{correctness metadata}
  metadata do |ast, filename|
    ast.xpath('//command[ident/@value="recipe"]').map do |declared_recipe|
      next unless declared_recipe.xpath("count(//vcall|//var_ref)").to_i == 0
      recipe_name = declared_recipe.xpath('args_add_block/
        descendant::tstring_content[1]/@value').to_s
      unless recipe_name.empty? ||
          recipe_name.split("::").first == cookbook_name(filename.to_s)
        declared_recipe
      end
    end.compact
  end
end

rule "FC030", "Cookbook contains debugger breakpoints" do
  tags %w{annoyances}
  def pry_bindings(ast)
    ast.xpath('//call[(vcall|var_ref)/ident/@value="binding"]
      [ident/@value="pry"]')
  end
  recipe { |ast| pry_bindings(ast) }
  library { |ast| pry_bindings(ast) }
  metadata { |ast| pry_bindings(ast) }
  template { |ast| pry_bindings(ast) }
end

rule "FC031", "Cookbook without metadata file" do
  tags %w{correctness metadata}
  cookbook do |filename|
    if !File.exist?(File.join(filename, "metadata.rb"))
      [file_match(File.join(filename, "metadata.rb"))]
    end
  end
end

rule "FC032", "Invalid notification timing" do
  tags %w{correctness notifications}
  recipe do |ast|
    valid_timings = if resource_attribute?("file", "notifies_before")
                      [:delayed, :immediate, :before]
                    else
                      [:delayed, :immediate]
    end
    find_resources(ast).select do |resource|
      notifications(resource).any? do |notification|
        ! valid_timings.include? notification[:timing]
      end
    end
  end
end

rule "FC033", "Missing template" do
  tags %w{correctness}
  recipe do |ast, filename|
    find_resources(ast, type: :template).reject do |resource|
      resource_attributes(resource)["local"] ||
        resource_attributes(resource)["cookbook"]
    end.map do |resource|
      file = template_file(resource_attributes(resource,
                                               return_expressions: true))
      { resource: resource, file: file }
    end.reject do |resource|
      resource[:file].respond_to?(:xpath)
    end.select do |resource|
      template_paths(filename).none? do |path|
        relative_path = []
        Pathname.new(path).ascend do |template_path|
          relative_path << template_path.basename
          break if gem_version(chef_version) >= gem_version("12.0.0") &&
              template_path.dirname.basename.to_s == "templates"
          break if template_path.dirname.dirname.basename.to_s == "templates"
        end
        File.join(relative_path.reverse) == resource[:file]
      end
    end.map { |resource| resource[:resource] }
  end
end

rule "FC034", "Unused template variables" do
  tags %w{correctness}
  recipe do |ast, filename|
    Array(resource_attributes_by_type(ast)["template"]).select do |t|
      t["variables"] && t["variables"].respond_to?(:xpath)
    end.map do |resource|
      all_templates = template_paths(filename)
      template_paths = all_templates.select do |path|
        File.basename(path) == template_file(resource)
      end
      next unless template_paths.any?
      passed_vars = resource["variables"].xpath(
        "symbol/ident/@value").map { |tv| tv.to_s }

      unused_vars_exist = template_paths.all? do |template_path|
        begin
          template_vars = templates_included(
            all_templates, template_path).map do |template|
            read_ast(template).xpath("//var_ref/ivar/@value").map do |v|
              v.to_s.sub(/^@/, "")
            end
          end.flatten
          ! (passed_vars - template_vars).empty?
        rescue RecursedTooFarError
          false
        end
      end
      file_match(template_paths.first) if unused_vars_exist
    end.compact
  end
end

rule "FC037", "Invalid notification action" do
  tags %w{correctness}
  recipe do |ast|
    find_resources(ast).select do |resource|
      notifications(resource).any? do |n|
        type = case n[:type]
               when :notifies then n[:resource_type]
               when :subscribes then resource_type(resource).to_sym
               end
        n[:action].size > 0 && !resource_action?(type, n[:action])
      end
    end
  end
end

rule "FC038", "Invalid resource action" do
  tags %w{correctness}
  recipe do |ast|
    find_resources(ast).select do |resource|
      actions = resource_attributes(resource)["action"]
      if actions.respond_to?(:xpath)
        actions = actions.xpath('descendant::array/
          descendant::symbol/ident/@value')
      else
        actions = Array(actions)
      end
      actions.reject { |a| a.to_s.empty? }.any? do |action|
        !resource_action?(resource_type(resource), action)
      end
    end
  end
end

rule "FC039", "Node method cannot be accessed with key" do
  tags %w{correctness}
  recipe do |ast|
    [{ type: :string, path: "@value" },
     { type: :symbol, path: "ident/@value" }].map do |access_type|
      attribute_access(ast, type: access_type[:type]).select do |att|
        att_name = att.xpath(access_type[:path]).to_s.to_sym
        att_name != :tags && chef_node_methods.include?(att_name)
      end.select do |att|
        !att.xpath('ancestor::args_add_block[position() = 1]
          [preceding-sibling::vcall | preceding-sibling::var_ref]').empty?
      end.select do |att|
        att_type = att.xpath('ancestor::args_add_block[position() = 1]
          /../var_ref/ident/@value').to_s
        ast.xpath("//assign/var_field/ident[@value='#{att_type}']").empty?
      end
    end.flatten
  end
end

rule "FC040", "Execute resource used to run git commands" do
  tags %w{style recipe etsy}
  recipe do |ast|
    possible_git_commands = %w{ clone fetch pull checkout reset }
    find_resources(ast, type: "execute").select do |cmd|
      cmd_str = (resource_attribute(cmd, "command") || resource_name(cmd)).to_s

      actual_git_commands = cmd_str.scan(/git ([a-z]+)/).map { |c| c.first }
      (possible_git_commands & actual_git_commands).any?
    end
  end
end

rule "FC041", "Execute resource used to run curl or wget commands" do
  tags %w{style recipe etsy}
  recipe do |ast|
    find_resources(ast, type: "execute").select do |cmd|
      cmd_str = (resource_attribute(cmd, "command") || resource_name(cmd)).to_s
      (cmd_str.match(/^curl.*(-o|>|--output).*$/) || cmd_str.include?("wget "))
    end
  end
end

rule "FC042", "Prefer include_recipe to require_recipe" do
  tags %w{deprecated}
  recipe do |ast|
    ast.xpath('//command[ident/@value="require_recipe"]')
  end
end

rule "FC043", "Prefer new notification syntax" do
  tags %w{style notifications deprecated}
  recipe do |ast|
    find_resources(ast).select do |resource|
      notifications(resource).any? { |notify| notify[:style] == :old }
    end
  end
end

rule "FC044", "Avoid bare attribute keys" do
  tags %w{style}
  attributes do |ast|
    declared = ast.xpath("//descendant::var_field/ident/@value").map do |v|
      v.to_s
    end

    ast.xpath('//assign/*[self::vcall or self::var_ref]
              [count(child::kw) = 0]/ident').select do |v|

      local_declared = v.xpath("ancestor::*[self::brace_block or self::do_block]
                                /block_var/descendant::ident/@value").map do |v|
        v.to_s
      end

      (v["value"] != "secure_password") &&
        !(declared + local_declared).uniq.include?(v["value"]) &&
        !v.xpath("ancestor::*[self::brace_block or self::do_block]/block_var/
                  descendant::ident/@value='#{v['value']}'")
    end
  end
end

rule "FC045", "Metadata does not contain cookbook name" do
  tags %w{correctness metadata chef12}
  metadata do |ast, filename|
    unless ast.xpath('descendant::stmts_add/command/ident/@value="name"')
      [file_match(filename)]
    end
  end
  cookbook do |filename|
    if !File.exist?(File.join(filename, "metadata.rb"))
      [file_match(File.join(filename, "metadata.rb"))]
    end
  end
end

rule "FC046", "Attribute assignment uses assign unless nil" do
  attributes do |ast|
    attribute_access(ast).map do |a|
      a.xpath('ancestor::opassign/op[@value="||="]')
    end
  end
end

rule "FC047", "Attribute assignment does not specify precedence" do
  tags %w{attributes correctness chef11}
  recipe do |ast|
    attribute_access(ast).map do |att|
      exclude_att_types = '[count(following-sibling::ident[
        is_att_type(@value) or @value = "run_state"]) = 0]'
      att.xpath(%Q{ancestor::assign[*[self::field | self::aref_field]
        [descendant::*[self::vcall | self::var_ref][ident/@value="node"]
        #{exclude_att_types}]]}, AttFilter.new) +
        att.xpath(%Q{ancestor::binary[@value="<<"]/*[position() = 1]
          [self::aref]
          [descendant::*[self::vcall | self::var_ref]#{exclude_att_types}
          /ident/@value="node"]}, AttFilter.new)
    end
  end
end

rule "FC048", "Prefer Mixlib::ShellOut" do
  tags %w{style processes}
  recipe do |ast|
    xstring_literal = ast.xpath("//xstring_literal")
    next xstring_literal if xstring_literal.any?

    ast.xpath('//*[self::command or self::fcall]/ident[@value="system"]').select do |x|
      resource_name = x.xpath("ancestor::do_block/preceding-sibling::command/ident/@value")
      next false if resource_name.any? && resource_name.all? { |r| resource_attribute?(r.to_s, "system") }
      next x.xpath('count(following-sibling::args_add_block/descendant::kw[@value="true" or @value="false"]) = 0')
    end
  end
end

rule "FC049", "Role name does not match containing file name" do
  tags %w{style roles}
  role do |ast, filename|
    role_name_specified = field_value(ast, :name)
    role_name_file = Pathname.new(filename).basename.sub_ext("").to_s
    if role_name_specified && role_name_specified != role_name_file
      field(ast, :name)
    end
  end
end

rule "FC050", "Name includes invalid characters" do
  tags %w{correctness environments roles}
  def invalid_name(ast)
    field(ast, :name) unless field_value(ast, :name) =~ /^[a-zA-Z0-9_\-]+$/
  end
  environment { |ast| invalid_name(ast) }
  role { |ast| invalid_name(ast) }
end

rule "FC051", "Template partials loop indefinitely" do
  tags %w{correctness}
  recipe do |_, filename|
    cbk_templates = template_paths(filename)

    cbk_templates.select do |template|
      begin
        templates_included(cbk_templates, template)
        false
      rescue RecursedTooFarError
        true
      end
    end.map { |t| file_match(t) }
  end
end

rule "FC052", 'Metadata uses the unimplemented "suggests" keyword' do
  tags %w{style metadata}
  metadata do |ast, filename|
    ast.xpath(%q{//command[ident/@value='suggests']})
  end
end

rule "FC053", 'Metadata uses the unimplemented "recommends" keyword' do
  tags %w{style metadata}
  metadata do |ast, filename|
    ast.xpath(%q{//command[ident/@value='recommends']})
  end
end

# NOTE: FC054 was yanked and should be considered reserved, do not reuse it

rule "FC055", "Ensure maintainer is set in metadata" do
  tags %w{correctness metadata}
  metadata do |ast, filename|
    [file_match(filename)] unless field(ast, "maintainer").any?
  end
end

rule "FC056", "Ensure maintainer_email is set in metadata" do
  tags %w{correctness metadata}
  metadata do |ast, filename|
    [file_match(filename)] unless field(ast, "maintainer_email").any?
  end
end

rule "FC057", "Library provider does not declare use_inline_resources" do
  tags %w{correctness}
  library do |ast, filename|
    ast.xpath('//const_path_ref/const[@value="LWRPBase"]/..//const[@value="Provider"]/../../..').select do |x|
      x.xpath('//*[self::vcall or self::var_ref]/ident[@value="use_inline_resources"]').empty?
    end
  end
end

rule "FC058", "Library provider declares use_inline_resources and declares #action_<name> methods" do
  tags %w{correctness}
  library do |ast, filename|
    ast.xpath('//const_path_ref/const[@value="LWRPBase"]/..//const[@value="Provider"]/../../..').select do |x|
      x.xpath('//*[self::vcall or self::var_ref]/ident[@value="use_inline_resources"]').length > 0 &&
        x.xpath(%q{//def[ident[contains(@value, 'action_')]]}).length > 0
    end
  end
end

rule "FC059", "LWRP provider does not declare use_inline_resources" do
  tags %w{correctness}
  provider do |ast, filename|
    use_inline_resources = !ast.xpath('//*[self::vcall or self::var_ref]/ident
      [@value="use_inline_resources"]').empty?
    unless use_inline_resources
      [file_match(filename)]
    end
  end
end

rule "FC060", "LWRP provider declares use_inline_resources and declares #action_<name> methods" do
  tags %w{correctness}
  provider do |ast, filename|
    use_inline_resources = !ast.xpath('//*[self::vcall or self::var_ref]/ident
      [@value="use_inline_resources"]').empty?
    if use_inline_resources
      ast.xpath(%q{//def[ident[contains(@value, 'action_')]]})
    end
  end
end

rule "FC061", "Valid cookbook versions are of the form x.y or x.y.z" do
  tags %w{metadata correctness}
  metadata do |ast, filename|
    # matches a version method with a string literal with no interpolation
    ver = ast.xpath('//command[ident/@value="version"]/args_add_block/args_add/string_literal[not(.//string_embexpr)]//tstring_content/@value')
    if !ver.empty? && ver.to_s !~ /\A\d+\.\d+(\.\d+)?\z/
      [file_match(filename)]
    end
  end
end

rule "FC062", "Cookbook should have version metadata" do
  tags %w{metadata}
  metadata do |ast, filename|
    [file_match(filename)] unless field(ast, "version").any?
  end
end

rule "FC063", "Cookbook incorrectly depends on itself" do
  tags %w{metadata correctness}
  metadata do |ast, filename|
    name = cookbook_name(filename)
    ast.xpath(%Q{//command[ident/@value='depends']/
              descendant::tstring_content[@value='#{name}']})
  end
end

rule "FC064", "Ensure issues_url is set in metadata" do
  tags %w{metadata supermarket chef12}
  metadata do |ast, filename|
    [file_match(filename)] unless field(ast, "issues_url").any?
  end
end

rule "FC065", "Ensure source_url is set in metadata" do
  tags %w{metadata supermarket chef12}
  metadata do |ast, filename|
    [file_match(filename)] unless field(ast, "source_url").any?
  end
end
