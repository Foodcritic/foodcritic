rule "FC040", "Execute resource used to run git commands" do
  tags %w{style}
  recipe do |ast|
    possible_git_commands = %w{ clone fetch pull checkout reset }
    find_resources(ast, type: "execute").select do |cmd|
      cmd_str = (resource_attribute(cmd, "command") || resource_name(cmd)).to_s

      actual_git_commands = cmd_str.scan(/git ([a-z]+)/).map(&:first)
      (possible_git_commands & actual_git_commands).any?
    end
  end
end
