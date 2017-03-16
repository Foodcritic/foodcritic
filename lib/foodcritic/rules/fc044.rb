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
