rule "FC001", "Use strings in preference to symbols to access node attributes" do
  tags %w{style attributes}
  recipe do |ast|
    attribute_access(ast, :symbol, false).map{|ar| match(ar)}
  end
end

rule "FC002", "Avoid string interpolation where not required" do
  tags %w{style strings}
  recipe do |ast|
    ast.xpath(%q{//string_literal[count(descendant::string_embexpr) = 1 and
      count(string_add/tstring_content|string_add/string_add/tstring_content) = 0]}).map{|str| match(str)}
  end
end

rule "FC003", "Check whether you are running with chef server before using server-specific features" do
  tags %w{portability solo}
  recipe do |ast,filename|
    searches(ast).map{|s| match(s)} unless checks_for_chef_solo?(ast) or chef_solo_search_supported?(filename)
  end
end

rule "FC004", "Use a service resource to start and stop services" do
  tags %w{style services}
  recipe do |ast|
    find_resources(ast, 'execute').find_all do |cmd|
      cmd_str = (resource_attribute('command', cmd) || resource_name(cmd)).to_s
      cmd_str.include?('/etc/init.d') || cmd_str.start_with?('service ') || cmd_str.start_with?('/sbin/service ') ||
          cmd_str.start_with?('start ') || cmd_str.start_with?('stop ') || cmd_str.start_with?('invoke-rc.d ')
    end.map{|cmd| match(cmd)}
  end
end

rule "FC005", "Avoid repetition of resource declarations" do
  tags %w{style}
  recipe do |ast|
    resources = find_resources(ast).map{|res| resource_attributes(res).merge({:type => resource_type(res),
      :ast => res})}.chunk{|res| res[:type]}.reject{|res| res[1].size < 3}
    resources.map do |cont_res|
      first_resource = cont_res[1][0][:ast]
      # we have contiguous resources of the same type, but do they share the same attributes?
      sorted_atts = cont_res[1].map{|atts| atts.delete_if{|k| k == :ast}.to_a.sort{|x,y| x.first.to_s <=> y.first.to_s}}
      match(first_resource) if sorted_atts.all?{|att| (att - sorted_atts.inject{|atts,a| atts & a}).length == 1}
    end.compact
  end
end

rule "FC006", "Mode should be quoted or fully specified when setting file permissions" do
  tags %w{correctness files}
  recipe do |ast|
    ast.xpath(%q{//ident[@value='mode']/parent::command/descendant::int[string-length(@value) < 5 and not(starts-with(@value, "0") and string-length(@value) = 4)]/
      ancestor::method_add_block}).map{|resource| match(resource)}
  end
end

rule "FC007", "Ensure recipe dependencies are reflected in cookbook metadata" do
  tags %w{correctness metadata}
  recipe do |ast,filename|
    metadata_path = Pathname.new(File.join(File.dirname(filename), '..', 'metadata.rb')).cleanpath
    next unless File.exists? metadata_path
    undeclared = included_recipes(ast).keys.map{|recipe|recipe.split('::').first} - [cookbook_name(filename)] -
        declared_dependencies(read_file(metadata_path))
    included_recipes(ast).map do |recipe, resource|
      match(resource) if undeclared.include?(recipe) || undeclared.any?{|u| recipe.start_with?("#{u}::")}
    end.compact
  end
end

rule "FC008", "Generated cookbook metadata needs updating" do
  tags %w{style metadata}
  cookbook do |filename|
    metadata_path = Pathname.new(File.join(filename, 'metadata.rb')).cleanpath
    next unless File.exists? metadata_path
    md = read_file(metadata_path)
    {'maintainer' => 'YOUR_COMPANY_NAME', 'maintainer_email' => 'YOUR_EMAIL'}.map do |field,value|
      md.xpath(%Q{//command[ident/@value='#{field}']/descendant::tstring_content[@value='#{value}']}).map do |m|
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
        resource.keys.map{|att|att.to_sym}.reject{|att| attribute?(type.to_sym, att)}.each do |invalid_att|
          matches << match(find_resources(ast, type).find{|res|resource_attributes(res).include?(invalid_att.to_s)})
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
    literal_searches(ast).reject{|search| valid_query?(search['value'])}.map{|search| match(search)}
  end
end

rule "FC011", "Missing README in markdown format" do
  tags %w{style readme}
  cookbook do |filename|
    [file_match(File.join(filename, 'README.md'))] unless File.exists?(File.join(filename, 'README.md'))
  end
end

rule "FC012", "Use Markdown for README rather than RDoc" do
  tags %w{style readme}
  cookbook do |filename|
    [file_match(File.join(filename, 'README.rdoc'))] if File.exists?(File.join(filename, 'README.rdoc'))
  end
end

rule "FC013", "Use file_cache_path rather than hard-coding tmp paths" do
  tags %w{style files}
  recipe do |ast|
    find_resources(ast, 'remote_file').find_all do |download|
      path = (resource_attribute('path', download) || resource_name(download)).to_s
      path.start_with?('/tmp/')
    end.map{|download| match(download)}
  end
end

rule "FC014", "Consider extracting long ruby_block to library" do
  tags %w{style libraries}
  recipe do |ast|
    find_resources(ast, 'ruby_block').find_all do |rb|
      ! rb.xpath("//fcall[ident/@value='block' and count(ancestor::*) = 8]/../../do_block[count(descendant::*) > 100]").empty?
    end.map{|block| match(block)}
  end
end

rule "FC015", "Consider converting definition to a LWRP" do
  tags %w{style definitions lwrp}
  cookbook do |dir|
    Dir[File.join(dir, 'definitions', '*.rb')].reject{|entry| ['.', '..'].include? entry}.map{|entry| file_match(entry)}
  end
end

rule "FC016", "LWRP does not declare a default action" do
  tags %w{correctness lwrp}
  resource do |ast, filename|
    ast.xpath("//def/bodystmt/descendant::assign/var_field/ivar/@value='@action'") ? [] : [file_match(filename)]
  end
end

rule "FC017", "LWRP does not notify when updated" do
  tags %w{correctness lwrp}
  provider do |ast, filename|
    if ast.xpath(%q{//call/*[self::vcall or self::var_ref/ident/@value='new_resource']/../
      ident[@value='updated_by_last_action']}).empty?
      [file_match(filename)]
    end
  end
end

rule "FC018", "LWRP uses deprecated notification syntax" do
  tags %w{style lwrp deprecated}
  provider do |ast|
    ast.xpath("//assign/var_field/ivar[@value='@updated']").map{|class_var| match(class_var)} +
    ast.xpath(%q{//assign/field/*[self::vcall or self::var_ref/ident/@value='new_resource']/../
      ident[@value='updated']}).map{|assign| match(assign)}
  end
end

rule "FC019", "Access node attributes in a consistent manner" do
  tags %w{style attributes}
  cookbook do |cookbook_dir|
    asts = {}; files = Dir["#{cookbook_dir}/*/*.rb"].map{|file| {:path => file, :ast => read_file(file)}}
    types = [:string, :symbol, :vivified].map{|type| {:access_type => type, :count => files.map do |file|
      attribute_access(file[:ast], type, true).tap{|ast|
        asts[type] = {:ast => ast, :path => file[:path]} if (! ast.empty?) and (! asts.has_key?(type))
      }.size
    end.inject(:+)}}.reject{|type| type[:count] == 0}
    if asts.size > 1
      least_used = asts[types.min{|a,b| a[:count] <=> b[:count]}[:access_type]]
      least_used[:ast].map{|ast| match(ast).merge(:filename => least_used[:path])}
    end
  end
end

rule "FC020", "Conditional execution string attribute looks like Ruby" do
  tags %w{correctness}
  recipe do |ast, filename|
    conditions = ast.xpath(%q{//command[(ident/@value='only_if' or ident/@value='not_if') and
      descendant::tstring_content]}).map{|m| match(m)}
    unless conditions.empty?
      lines = File.readlines(filename) # go back and get the raw untokenized string
      conditions.map do |condition|
        {:match => condition, :raw_string => lines[(condition[:line].to_i) -1].strip.sub(/^(not|only)_if[\s+]["']/, '').chop}
      end.find_all{|cond| ruby_code?(cond[:raw_string]) and ! os_command?(cond[:raw_string])}.map{|cond| cond[:match]}
    end
  end
end

rule "FC021", "Resource condition in provider may not behave as expected" do
  tags %w{correctness lwrp}
  provider do |ast|
    find_resources(ast).map do |resource|
      condition = resource.xpath(%q{//method_add_block/descendant::ident[@value='not_if' or @value='only_if']/
        ancestor::*[self::method_add_block or self::command][1][descendant::ident/@value='new_resource']/
        ancestor::stmts_add[2]/method_add_block/command[count(descendant::string_embexpr) = 0]})
      match(condition) unless condition.empty?
    end.compact
  end
end

rule "FC022", "Resource condition within loop may not behave as expected" do
  tags %w{correctness}
  recipe do |ast|
    ast.xpath("//call[ident/@value='each']/../do_block").map do |loop|
      block_vars = loop.xpath("block_var/params/child::*").map{|n| n.name.sub(/^ident/, '')}
      find_resources(loop).map do |resource|
        # if any of the parameters to the block are used in a condition then we have a match
        unless (block_vars & (resource.xpath(%q{descendant::ident[@value='not_if' or @value='only_if']/
          ancestor::*[self::method_add_block or self::command][1]/descendant::ident/@value}).map{|a| a.value})).empty?
          match(resource) unless resource.xpath('command[count(descendant::string_embexpr) = 0]').empty?
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
      [count(stmts_add/stmts_add) = 0]}).map{|condition| match(condition)}
  end
end
