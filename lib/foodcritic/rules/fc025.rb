rule "FC025", "Prefer chef_gem to compile-time gem install" do
  tags %w{correctness deprecated}
  recipe do |ast|
    # when Ruby 2.4 support goes away this can be simplified to remove the
    # do_block/stmts_add/command case which is Ruby 2.4
    gem_install = ast.xpath("//stmts_add/assign[method_add_block[command/ident/
      @value='gem_package'][do_block/bodystmt/stmts_add/command[ident/@value='action'] | do_block/stmts_add/command[ident/@value='action']
      [descendant::ident/@value='nothing']]]")
    gem_install.map do |install|
      gem_var = install.xpath("var_field/ident/@value")
      unless ast.xpath("//method_add_arg[call/
        var_ref/ident/@value='#{gem_var}']
        [arg_paren/descendant::ident/@value='install' or
         arg_paren/descendant::ident/@value='upgrade']").empty?
        gem_install
      end
    end
  end
end
