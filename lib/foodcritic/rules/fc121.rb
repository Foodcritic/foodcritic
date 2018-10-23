# I'm disabling this rule until Chef 13 goes EOL
# It's causing a lot of confusion and resulting in folks dropping support
# for Chef 13 before they need to.
#
# rule "FC121", "Cookbook depends on cookbook made obsolete by Chef 14" do
#   tags %w{correctness}
#   metadata do |ast, filename|
#     [file_match(filename)] unless (declared_dependencies(ast) & %w{build-essential dmg chef_handler chef_hostname mac_os_x swap sysctl}).empty?
#   end
# end
