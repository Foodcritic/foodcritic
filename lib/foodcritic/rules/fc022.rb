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
                    self::command][1]/descendant::ident/@value}).map(&:value))).empty?
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
