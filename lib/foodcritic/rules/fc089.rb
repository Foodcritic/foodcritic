rule "FC089", "Prefer Mixlib::Shellout over Chef::ShellOut" do
  tags %w{chef13 deprecated}

  def old_shellout(ast)
    ast.xpath('//const_path_ref[var_ref/const[@value="Chef"]]/const[@value="ShellOut"]')
  end

  resource { |ast| old_shellout(ast) }
  recipe { |ast| old_shellout(ast) }
  library { |ast| old_shellout(ast) }
end
