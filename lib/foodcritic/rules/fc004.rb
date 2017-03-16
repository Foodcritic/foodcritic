rule "FC004", "Use a service resource to start and stop services" do
  tags %w{portability services}
  recipe do |ast|
    find_resources(ast, type: "execute").find_all do |cmd|
      cmd_str = (resource_attribute(cmd, "command") || resource_name(cmd)).to_s
      (cmd_str.include?("/etc/init.d") || ["service ", "/sbin/service ",
       "start ", "stop ", "invoke-rc.d "].any? do |service_cmd|
         cmd_str.start_with?(service_cmd)
       end) && %w{start stop restart reload}.any? { |a| cmd_str.include?(a) }
    end
  end
end
