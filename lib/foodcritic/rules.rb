rule "FC002", "Avoid string interpolation where not required" do
  description "When setting a resource value avoid string interpolation where not required."
  recipe do |ast|
    matches = []
    ast(:string_literal, ast).each do |literal|
      embed_expr = ast(:string_embexpr, literal)
      if embed_expr.size == 1
        literal[1].reject! { |expr| expr == embed_expr.first }
        if ast(:@tstring_content, literal).empty?
          ast(:@ident, embed_expr).map { |ident| ident.flatten.drop(1) }.each do |ident|
            matches << {:matched => ident[0], :line => ident[1], :column => ident[2]}
          end
        end
      end
    end
    matches
  end
end

rule "FC003", "Check whether you are running with chef server before using server-specific features" do
  description "Ideally your cookbooks should be usable without requiring chef server."
  recipe do |ast|
    matches = []
    function_calls = ast(:@ident, ast(:fcall, ast)).map { |fcall| fcall.drop(1).flatten }
    searches = function_calls.find_all { |fcall| fcall.first == 'search' }
    unless searches.empty? || checks_for_chef_solo?(ast)
      searches.each { |s| matches << {:matched => s[0], :line => s[1], :column => s[2]} }
    end
    matches
  end
end

rule "FC004", "Use a service resource to start and stop services" do
  description "Avoid use of execute to control services - use the service resource instead."
  recipe do |ast|
    matches = []
    find_resources(ast, 'execute').find_all do |cmd|
      cmd_str = resource_attribute('command', cmd)
      cmd_str = resource_name(cmd) if cmd_str.nil?
      cmd_str.include?('/etc/init.d') || cmd_str.start_with?('service ') || cmd_str.start_with?('/sbin/service ')
    end.each do |service_cmd|
      exec = ast(:@ident, service_cmd).first.drop(1).flatten
      matches << {:matched => exec[0], :line => exec[1], :column => exec[2]}
    end
    matches
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
          first_resource = ast(:@ident, find_resources(ast, type).first).first[2]
          matches << {:matched => type, :line => first_resource[0], :column => first_resource[1]}
        end
    end
    matches
  end
end