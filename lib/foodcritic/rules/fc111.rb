rule "FC111", "search using deprecated sort flag" do
  tags %w{deprecation chef13}
  recipe do |ast|
    # search(:node, 'role:web', :sort => true)
    ast.xpath("//method_add_arg[fcall/ident/@value='search'][arg_paren/args_add_block/args_add/bare_assoc_hash/assoc_new/symbol/ident/@value = 'sort']")
  end
end
