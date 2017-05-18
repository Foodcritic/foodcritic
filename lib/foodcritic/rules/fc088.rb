rule "FC088", "Prefer Mixlib::Shellout over Chef::Mixin::Command" do
  tags %w{chef13 deprecated}

  def includes_command(ast)
    ast.xpath('//const_path_ref/const[@value="Command"]/..//const[@value="Mixin"]/..//const[@value="Chef"]')
  end

  resource { |ast| includes_command(ast) }
  recipe { |ast| includes_command(ast) }
  library { |ast| includes_command(ast) }
end
