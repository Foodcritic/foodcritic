rule "FC004", "Use a service resource to start and stop services" do
  tags %w{portability services}
  recipe do |ast|
    find_resources(ast, type: "execute").find_all do |cmd|
      cmd_str = (resource_attribute(cmd, "command") || resource_name(cmd)).to_s
      next if cmd_str.include?(".exe") # don't catch windows commands
      cmd_str.start_with?( "start ", "stop ", "reload ", "restart ") || # upstart jobs
        ( [ "/etc/init.d", "service ", "/sbin/service ", "invoke-rc.d ", "systemctl "].any? do |service_cmd| # upstart / sys-v / systemd
          cmd_str.start_with?(service_cmd)
        end && [" start", " stop", " restart", " reload"].any? { |a| cmd_str.include?(a) } ) # make sure we get exactly the commands not something like 'daemon-reload'
    end
  end
end
