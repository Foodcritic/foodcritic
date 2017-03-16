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
