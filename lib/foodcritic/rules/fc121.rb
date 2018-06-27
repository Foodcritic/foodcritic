rule "FC121", "Cookbook depends on cookbook where resources are built into Chef 14" do
  tags %w{correctness}
  metadata do |ast, filename|
    [file_match(filename)] unless (declared_dependencies(ast) & %w{build-essential dmg chef_handler chef_hostname mac_os_x swap sysctl}).empty?
  end
end
