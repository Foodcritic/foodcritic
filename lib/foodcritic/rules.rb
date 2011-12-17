rule "FC001", "Use strings in preference to symbols to access node attributes" do
  tags %w{style attributes}
  description "When accessing node attributes you should use a string for a key rather than a symbol."
  recipe do |ast|
    %w{node default override set normal}.map do |type|
      ast.xpath("//*[self::aref_field or self::aref][vcall/ident/@value='#{type}']//symbol").map{|ar| match(ar)}
    end.flatten
  end
end

rule "FC002", "Avoid string interpolation where not required" do
  tags %w{style strings}
  description "When setting a resource value avoid string interpolation where not required."
  recipe do |ast|
    ast.xpath(%q{//string_literal[count(descendant::string_embexpr) = 1 and
      count(string_add/tstring_content|string_add/string_add/tstring_content) = 0]}).map{|str| match(str)}
  end
end

rule "FC003", "Check whether you are running with chef server before using server-specific features" do
  tags %w{portability solo}
  description "Ideally your cookbooks should be usable without requiring chef server."
  recipe do |ast|
    checks_for_chef_solo?(ast) ? [] : searches(ast).map{|s| match(s)}
  end
end

rule "FC004", "Use a service resource to start and stop services" do
  tags %w{style services}
  description "Avoid use of execute to control services - use the service resource instead."
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
  description "Where you have a lot of resources that vary in only a single attribute wrap them in a loop for brevity."
  recipe do |ast|
    matches = []
    # do all of the attributes for all resources of a given type match apart aside from one?
    resource_attributes_by_type(ast).each do |type, resource_atts|
        sorted_atts = resource_atts.map{|atts| atts.to_a.sort{|x,y| x.first.to_s <=> y.first.to_s }}
        if sorted_atts.all?{|att| (att - sorted_atts.inject{|atts,a| atts & a}).length == 1}
          matches << match(find_resources(ast, type).first)
        end
    end
    matches
  end
end

rule "FC006", "Mode should be quoted or fully specified when setting file permissions" do
  tags %w{correctness files}
  description "Not quoting mode when setting permissions can lead to incorrect permissions being set."
  recipe do |ast|
    ast.xpath(%q{//ident[@value='mode']/parent::command/descendant::int[string-length(@value) < 4]/
      ancestor::method_add_block}).map{|resource| match(resource)}
  end
end

rule "FC007", "Ensure recipe dependencies are reflected in cookbook metadata" do
  tags %w{correctness metadata}
  description "You are including a recipe that is not in the current cookbook and not defined as a dependency in your cookbook metadata."
  recipe do |ast,filename|
    metadata_path = Pathname.new(File.join(File.dirname(filename), '..', 'metadata.rb')).cleanpath
    next unless File.exists? metadata_path
    undeclared = included_recipes(ast).keys.map{|recipe|recipe.split('::').first} - [cookbook_name(filename)] -
        declared_dependencies(read_file(metadata_path))
    included_recipes(ast).map do |recipe, resource|
      match(resource).merge(:filename => metadata_path) if undeclared.include?(recipe) || undeclared.any?{|u| recipe.start_with?("#{u}::")}
    end.compact
  end
end

rule "FC008", "Generated cookbook metadata needs updating" do
  tags %w{style metadata}
  description "The cookbook metadata for this cookbook is boilerplate output from knife generate cookbook and needs updating with the real details of your cookbook."
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
  description "You appear to be using an unrecognised attribute on a standard Chef resource. Please check for typos."
  recipe do |ast|
    matches = []
    resource_attributes_by_type(ast).each do |type,resources|
      if Chef::Resource.const_defined?(convert_to_class_name(type))
        allowed_atts = Chef::Resource.const_get(convert_to_class_name(type)).public_instance_methods(true)
        resources.each do |resource|
          invalid_atts = resource.keys.map{|att|att.to_sym} - allowed_atts
          unless invalid_atts.empty?
            matches << match(find_resources(ast, type).find{|res|resource_attributes(res).include?(invalid_atts.first.to_s)})
          end
        end
      end
    end
    matches
  end
end

rule "FC010", "Invalid search syntax" do
  tags %w{correctness search}
  description "The search expression in the recipe could not be parsed. Please check your syntax."
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
  tags %w{style}
  recipe do |ast|
    find_resources(ast, 'ruby_block').find_all do |rb|
      ! rb.xpath("//fcall[ident/@value='block' and count(ancestor::*) = 8]/../../do_block[count(descendant::*) > 100]").empty?
    end.map{|block| match(block)}
  end
end