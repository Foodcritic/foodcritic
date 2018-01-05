rule "FC114", "Cookbook uses legacy Ohai config syntax" do
  tags %w{chef13 deprecated}
  recipe do |ast|
    # Ohai::Config[:something]
    #
    # <aref value="aref"> <-- if assigning this will be aref_field
    #   <const_path_ref value="const_path_ref">
    #     <var_ref value="var_ref">
    #       <const value="Ohai">
    #         <pos line="3" column="0"/>
    #       </const>
    #     </var_ref>
    #     <const value="Config">
    #       <pos line="3" column="6"/>
    #     </const>
    #   </const_path_ref>
    #   <args_add_block value="false">
    #     <args_add value="args_add">
    #       <args_new value="args_new"/>
    #       <symbol_literal value="symbol_literal">
    #         <symbol value="symbol">
    #           <ident value="something">
    #             <pos line="3" column="14"/>
    #           </ident>
    #         </symbol>
    #       </symbol_literal>
    #     </args_add>
    #   </args_add_block>
    # </aref>
    ast.xpath('//*[self::aref or self::aref_field][const_path_ref/const/@value="Config"][const_path_ref/var_ref/const/@value="Ohai"][args_add_block/args_add/symbol_literal/symbol]')
  end
end
