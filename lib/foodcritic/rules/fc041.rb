rule "FC041", "Execute resource used to run curl or wget commands" do
  tags %w{style recipe etsy}
  recipe do |ast|
    find_resources(ast, type: "execute").select do |cmd|
      cmd_str = (resource_attribute(cmd, "command") || resource_name(cmd)).to_s
      (cmd_str.match(/^curl.*(-o|>|--output).*$/) || cmd_str.include?("wget "))
    end
  end
end
