rule "FC085", "Resource using new_resource.updated_by_last_action to converge resource" do
  tags %w{correctness}
  def updated_by(ast)
    # we need to handle both @new_resource.updated_by_last_action(true) or new_resource.updated_by_last_action(true)
    # Here's the ast that xpath sees in all 3 possible scenarios from those two:
    # <call value=".">
    #   <vcall value="vcall">
    #     <ident value="new_resource">
    #       <pos line="26" column="0"/>
    #     </ident>
    #   </vcall>
    #   <ident value="updated_by_last_action">
    #     <pos line="26" column="13"/>
    #   </ident>
    # </call>
    #
    # <call value=".">
    #   <var_ref value="var_ref">
    #     <ivar value="@new_resource">
    #       <pos line="25" column="0"/>
    #     </ivar>
    #   </var_ref>
    #   <ident value="updated_by_last_action">
    #     <pos line="25" column="14"/>
    #   </ident>
    # </call>
    #
    # <call value=".">
    #   <var_ref value="var_ref">
    #     <ident value="new_resource">
    #       <pos line="27" column="0"/>
    #     </ident>
    #   </vcall>
    #   <ident value="updated_by_last_action">
    #     <pos line="27" column="13"/>
    #   </ident>
    # </call>
    ast.xpath('descendant::*[self::var_ref/ident/@value="new_resource" or self::vcall/ident/@value="new_resource" or self::var_ref/ivar/@value="@new_resource"]/../ident[@value="updated_by_last_action"]')
  end

  resource { |ast| updated_by(ast) }
  provider { |ast| updated_by(ast) }
  library { |ast| updated_by(ast) }

end
