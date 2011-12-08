rule "FC002", "Avoid string interpolation where not required" do
  description "When setting a resource value avoid string interpolation where not required."
  recipe do |ast|
    ast.xpath(%q{//string_literal[count(descendant::string_embexpr) = 1 and
      count(string_add/tstring_content|string_add/string_add/tstring_content) = 0]}).map{|str| match(str)}
  end
end

rule "FC003", "Check whether you are running with chef server before using server-specific features" do
  description "Ideally your cookbooks should be usable without requiring chef server."
  recipe do |ast|
    checks_for_chef_solo?(ast) ? [] : searches(ast).map{|s| match(s)}
  end
end

rule "FC004", "Use a service resource to start and stop services" do
  description "Avoid use of execute to control services - use the service resource instead."
  recipe do |ast|
    find_resources(ast, 'execute').find_all do |cmd|
      cmd_str = (resource_attribute('command', cmd) || resource_name(cmd)).to_s
      cmd_str.include?('/etc/init.d') || cmd_str.start_with?('service ') || cmd_str.start_with?('/sbin/service ')
    end.map{|cmd| match(cmd)}
  end
end

rule "FC005", "Avoid repetition of resource declarations" do
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
  description "Not quoting mode when setting permissions can lead to incorrect permissions being set."
  recipe do |ast|
    ast.xpath(%q{//ident[@value='mode']/parent::command/descendant::int[string-length(@value) < 4]/
      ancestor::method_add_block}).map{|resource| match(resource)}
  end
end

rule "FC007", "Ensure recipe dependencies are reflected in cookbook metadata" do
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
  description "The cookbook metadata for this cookbook is boilerplate output from knife generate cookbook and needs updating with the real details of your cookbook."
  recipe do |ast,filename|
    metadata_path = Pathname.new(File.join(File.dirname(filename), '..', 'metadata.rb')).cleanpath
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