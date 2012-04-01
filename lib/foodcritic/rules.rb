rule "FC001",
     "Use strings in preference to symbols to access node attributes" do
  tags %w{style attributes}
  recipe do |ast|
    attribute_access(ast, :type => :symbol)
  end
end

rule "FC002", "Avoid string interpolation where not required" do
  tags %w{style strings}
  recipe do |ast|
    ast.xpath(%q{//string_literal[count(descendant::string_embexpr) = 1 and
      count(string_add/tstring_content|string_add/string_add/tstring_content)
      = 0]})
  end
end

rule "FC003",
     "Check whether you are running with chef server before using" +
     " server-specific features" do
  tags %w{portability solo}
  recipe do |ast,filename|
    unless checks_for_chef_solo?(ast) or chef_solo_search_supported?(filename)
      searches(ast)
    end
  end
end

rule "FC004", "Use a service resource to start and stop services" do
  tags %w{style services}
  recipe do |ast|
    find_resources(ast, :type => 'execute').find_all do |cmd|
      cmd_str = (resource_attribute(cmd, 'command') || resource_name(cmd)).to_s
      (cmd_str.include?('/etc/init.d') || ['service ', '/sbin/service ',
       'start ', 'stop ', 'invoke-rc.d '].any? do |service_cmd|
          cmd_str.start_with?(service_cmd)
        end) && %w{start stop restart reload}.any?{|a| cmd_str.include?(a)}
    end
  end
end

rule "FC005", "Avoid repetition of resource declarations" do
  tags %w{style}
  recipe do |ast|
    resources = find_resources(ast).map do |res|
      resource_attributes(res).merge({:type => resource_type(res),
                                      :ast => res})
    end.chunk do |res|
      res[:type] +
      res[:ast].xpath("ancestor::*[self::if | self::unless | self::elsif |
        self::else | self::when | self::method_add_block/call][position() = 1]/
        descendant::pos[position() = 1]").to_s +
      res[:ast].xpath("ancestor::method_add_block/command[
        ident/@value='action']/args_add_block/descendant::ident/@value").to_s
    end.reject{|res| res[1].size < 3}
    resources.map do |cont_res|
      first_resource = cont_res[1][0][:ast]
      # we have contiguous resources of the same type, but do they share the
      # same attributes?
      sorted_atts = cont_res[1].map do |atts|
        atts.delete_if{|k| k == :ast}.to_a.sort do |x,y|
          x.first.to_s <=> y.first.to_s
        end
      end
      first_resource if sorted_atts.all? do |att|
        (att - sorted_atts.inject{|atts,a| atts & a}).length == 1
      end
    end.compact
  end
end

rule "FC006",
     "Mode should be quoted or fully specified when setting file permissions" do
  tags %w{correctness files}
  recipe do |ast|
    ast.xpath(%q{//ident[@value='mode']/parent::command/
      descendant::int[string-length(@value) < 5 and not(starts-with(@value, "0")
      and string-length(@value) = 4)]/ancestor::method_add_block})
  end
end

rule "FC007", "Ensure recipe dependencies are reflected in cookbook metadata" do
  tags %w{correctness metadata}
  recipe do |ast,filename|
    metadata_path =Pathname.new(
      File.join(File.dirname(filename), '..', 'metadata.rb')).cleanpath
    next unless File.exists? metadata_path
    undeclared = included_recipes(ast).keys.map do |recipe|
      recipe.split('::').first
    end - [cookbook_name(filename)] -
        declared_dependencies(read_ast(metadata_path))
    included_recipes(ast).map do |recipe, include_stmts|
      if undeclared.include?(recipe) ||
         undeclared.any?{|u| recipe.start_with?("#{u}::")}
        include_stmts
      end
    end.flatten.compact
  end
end

rule "FC008", "Generated cookbook metadata needs updating" do
  tags %w{style metadata}
  cookbook do |filename|
    metadata_path = Pathname.new(File.join(filename, 'metadata.rb')).cleanpath
    next unless File.exists? metadata_path
    md = read_ast(metadata_path)
    {'maintainer' => 'YOUR_COMPANY_NAME',
     'maintainer_email' => 'YOUR_EMAIL'}.map do |field,value|
      md.xpath(%Q{//command[ident/@value='#{field}']/
                  descendant::tstring_content[@value='#{value}']}).map do |m|
        match(m).merge(:filename => metadata_path)
      end
    end.flatten
  end
end

rule "FC009", "Resource attribute not recognised" do
  tags %w{correctness}
  recipe do |ast|
    matches = []
    resource_attributes_by_type(ast).each do |type,resources|
      resources.each do |resource|
        resource.keys.map(&:to_sym).reject do |att|
          resource_attribute?(type.to_sym, att)
        end.each do |invalid_att|
          matches << find_resources(ast, :type => type).find do |res|
            resource_attributes(res).include?(invalid_att.to_s)
          end
        end
      end
    end
    matches
  end
end

rule "FC010", "Invalid search syntax" do
  tags %w{correctness search}
  recipe do |ast|
    # This only works for literal search strings
    literal_searches(ast).reject{|search| valid_query?(search['value'])}
  end
end

rule "FC011", "Missing README in markdown format" do
  tags %w{style readme}
  cookbook do |filename|
    unless File.exists?(File.join(filename, 'README.md'))
      [file_match(File.join(filename, 'README.md'))]
    end
  end
end

rule "FC012", "Use Markdown for README rather than RDoc" do
  tags %w{style readme}
  cookbook do |filename|
    if File.exists?(File.join(filename, 'README.rdoc'))
      [file_match(File.join(filename, 'README.rdoc'))]
    end
  end
end

rule "FC013", "Use file_cache_path rather than hard-coding tmp paths" do
  tags %w{style files}
  recipe do |ast|
    find_resources(ast, :type => 'remote_file').find_all do |download|
      path = (resource_attribute(download, 'path') ||
        resource_name(download)).to_s
      path.start_with?('/tmp/')
    end
  end
end

rule "FC014", "Consider extracting long ruby_block to library" do
  tags %w{style libraries}
  recipe do |ast|
    find_resources(ast, :type => 'ruby_block').find_all do |rb|
      ! rb.xpath("//fcall[ident/@value='block' and count(ancestor::*) = 8]/../
                  ../do_block[count(descendant::*) > 100]").empty?
    end
  end
end

rule "FC015", "Consider converting definition to a LWRP" do
  tags %w{style definitions lwrp}
  cookbook do |dir|
    Dir[File.join(dir, 'definitions', '*.rb')].reject do |entry|
      ['.', '..'].include? entry
    end.map{|entry| file_match(entry)}
  end
end

rule "FC016", "LWRP does not declare a default action" do
  tags %w{correctness lwrp}
  resource do |ast, filename|
    unless ["//ident/@value='default_action'",
     "//def/bodystmt/descendant::assign/
      var_field/ivar/@value='@action'"].any? {|expr| ast.xpath(expr)}
      [file_match(filename)]
    end
  end
end

rule "FC017", "LWRP does not notify when updated" do
  tags %w{correctness lwrp}
  provider do |ast, filename|
    if ast.xpath(%q{//call/*[self::vcall or self::var_ref/ident/
                 @value='new_resource']/../
                 ident[@value='updated_by_last_action']}).empty?
      [file_match(filename)]
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
    asts = {}; files = Dir["#{cookbook_dir}/*/*.rb"].map do |file|
      {:path => file, :ast => read_ast(file)}
    end
    types = [:string, :symbol, :vivified].map do |type|
      {:access_type => type, :count => files.map do |file|
        attribute_access(file[:ast], :type => type,
                         :ignore_calls => true).tap do |ast|
          if (! ast.empty?) and (! asts.has_key?(type))
            asts[type] = {:ast => ast, :path => file[:path]}
          end
        end.size
      end.inject(:+)}
    end.reject{|type| type[:count] == 0}
    if asts.size > 1
      least_used = asts[types.min{|a,b| a[:count] <=> b[:count]}[:access_type]]
      least_used[:ast].map do |ast|
        match(ast).merge(:filename => least_used[:path])
      end
    end
  end
end

rule "FC020", "Conditional execution string attribute looks like Ruby" do
  tags %w{correctness}
  recipe do |ast, filename|
    conditions = ast.xpath(%q{//command[(ident/@value='only_if' or ident/
      @value='not_if') and descendant::tstring_content]}).map{|m| match(m)}
    unless conditions.empty?
      lines = File.readlines(filename) # go back for the raw untokenized string
      conditions.map do |condition|
        line = lines[(condition[:line].to_i) -1]
        {:match => condition,
         :raw_string => line.strip.sub(/^(not|only)_if[\s+]["']/, '').chop}
      end.find_all do |cond|
        ruby_code?(cond[:raw_string]) and
          ! os_command?(cond[:raw_string])
      end.map{|cond| cond[:match]}
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
    ast.xpath("//call[ident/@value='each']/../do_block").map do |loop|
      block_vars = loop.xpath("block_var/params/child::*").map do |n|
        n.name.sub(/^ident/, '')
      end
      find_resources(loop).map do |resource|
        # if any of the parameters to the block are used in a condition then we
        # have a match
        unless (block_vars &
          (resource.xpath(%q{descendant::ident[@value='not_if' or
          @value='only_if']/ancestor::*[self::method_add_block or
          self::command][1]/descendant::ident/@value}).map{|a| a.value})).empty?
          c = resource.xpath('command[count(descendant::string_embexpr) = 0]')
          resource unless c.empty?
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
  RHEL = %w{amazon centos redhat scientific}
  recipe do |ast|
    ['//method_add_arg[fcall/ident/@value="platform?"]/arg_paren/args_add_block',
     "//when"].map do |expr|
      ast.xpath(expr).map do |whn|
        platforms = whn.xpath("args_add/descendant::tstring_content").map do |p|
          p['value']
        end
        unless platforms.size == 1 || (RHEL & platforms).empty?
          unless (RHEL - platforms).empty?
            whn
          end
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
      unless ast.xpath("//method_add_arg[call/var_ref/ident/@value='#{gem_var}']
        [arg_paren/descendant::ident/@value='install' or
         arg_paren/descendant::ident/@value='upgrade']").empty?
        gem_install
      end
    end
  end
end
