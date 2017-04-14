rule "FC028", "Use platform? and platform_family? not node.platform? and node.platform_family?" do
  tags %w{style}
  recipe do |ast|
    ast.xpath(%q{//*[self::call | self::command_call]
      [(var_ref|vcall)/ident/@value='node']
      [ident/@value="platform?" or ident/@value="platform_family?"]})
  end
end
