rule "FC089", "Prefer Mixlib::Shellout over Chef::ShellOut" do
  tags %w{chef13 deprecated}

  def old_shellout(ast)
    ast.xpath('//const[@value="ShellOut"]/..//const[@value="Chef"]')
  end

  resource { |ast| old_shellout(ast) }
  recipe { |ast| old_shellout(ast) }
  library { |ast| old_shellout(ast) }
end
