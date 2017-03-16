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
