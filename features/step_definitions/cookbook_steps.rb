Given 'a cookbook attributes file that declares and refers to a local variable' do
  write_attributes %q{
    master = search(:nodes, 'foo:master')
    default[:foo][:master] = master
  }
end

Given /^a cookbook attributes file that refers to an attribute with (.*)$/ do |reference|
  write_attributes %Q{
    default['myhostname'] = #{reference}
  }
end

Given 'a cookbook attributes file that sets an attribute to be the result of a library call' do
  write_attributes %q{
    ::Chef::Node.send(:include, Opscode::OpenSSL::Password)
    default[:admin_password] = secure_password
  }
end

Given 'a cookbook attributes file with a brace block that takes arguments' do
  write_attributes %q{
    foo = {'foo' => 'bar'}
    foo.each{|k, v| default['waka'][k] = v}
  }
end

Given 'a cookbook attributes file with a do block that takes arguments' do
  write_attributes %q{
    foo = {'foo' => 'bar'}
    foo.each do |k, v|
      default['waka'][k] = v
    end
  }
end

Given /^a cookbook (attributes|recipe) file with assignment (.*)$/ do |type, assignment|
  if type == 'attributes'
    write_attributes assignment
  else
    write_recipe assignment
  end
end

Given "a cookbook recipe that contains a group resource that uses the 'system' attribute" do
  write_recipe %q{
    group "senge" do
      system true
    end
  }
end

Given /^a cookbook recipe that declares (too many )?execute resources varying only in the command in branching conditionals$/ do |too_many|
  extra_resource = %q{
    execute "bing" do
      action :run
    end
  }
  write_recipe %Q{
    if true
      execute "foo" do
        action :run
      end
    else
      #{extra_resource if too_many}
      execute "bar" do
        action :run
      end
      execute "baz" do
        action :run
      end
    end
  }.strip
end

Given /^a cookbook recipe that declares a ([^ ]+) resource with the ([^ ]+) attribute set to (.*)$/ do |resource, attribute, value|
  write_recipe %Q{
    #{resource} "foo" do
      #{attribute} #{value}
    end
  }
end

Given /^a cookbook recipe that executes '([^']+)' with an execute resource$/ do |command|
  write_recipe %Q{
    execute "#{command}" do
      action :run
    end
  }
end

Given /^a cookbook recipe that spawns a sub-process with (.*)$/ do |command|
  write_recipe command
end

Given 'a cookbook recipe with a deploy resource that contains a template resource' do
  write_recipe %q{
    deploy '/foo/bar' do
      before_restart do
        template "/tmp/config.conf" do
          source "foo.conf.erb"
          variables({
            :config_var => 'foo'
          })
	end
      end
    end
  }
  write_file "cookbooks/example/templates/default/foo.conf.erb", %q{
    <%= @config_var %>
  }
end

Given 'a cookbook recipe with a resource that notifies where the action is an expression' do
  write_recipe %q{
    notify_action = node['platform_family'] == "mac_os_x" ? :restart : :reload

    service 'svc' do
      action :nothing
    end

    template '/tmp/foo' do
      source 'foo.erb'
      notifies notify_action, 'service[svc]'
    end
  }
end

Given /^a cookbook recipe with an execute resource named (.*)$/ do |name|
  write_recipe %Q{
    execute "#{name}" do
      action :run
    end
  }
end

Given /^a cookbook recipe with an execute resource that runs the command (.*)$/ do |command|
  write_recipe %Q{
    execute "do_stuff" do
      command "#{command}"
    end
  }
end

Given /^a cookbook recipe that refers to (node.*)$/ do |reference|
  write_recipe %Q{
    Chef::Log.info #{reference}
  }
end

Given 'a cookbook recipe that refers to an attribute with a bare keyword' do
  write_recipe %q{
    node['myhostname'] = hostname
  }
end

Given /^a cookbook recipe that wraps a platform\-specific resource in a (.*) conditional$/ do |conditional|
  write_recipe %Q{
    if #{conditional}
      Chef::Log.info('We matched the platform')
    end
  }
end

Given 'a cookbook provider that declares execute resources varying only in the command in separate actions' do
  write_provider 'site', %q{
    action :start do
      execute "foo" do
        action :run
      end
      new_resource.updated_by_last_action(true)
    end
    action :stop do
      execute "bar" do
        action :run
      end
      new_resource.updated_by_last_action(true)
    end
    action :restart do
      execute "baz" do
        action :run
      end
      new_resource.updated_by_last_action(true)
    end
  }.strip
end

Given 'a cookbook provider that declares execute resources varying only in the command in the same action' do
  write_provider 'site', %q{
    action :start do
      execute "foo" do
        action :run
      end
      execute "bar" do
        action :run
      end
      execute "baz" do
        action :run
      end
      new_resource.updated_by_last_action(true)
    end
  }.strip
end

Given /^a cookbook recipe that attempts to perform a search with (.*)$/ do |search_type|
  recipe_with_search(search_type.include?('subexpression') ? :with_subexpression : search_type.gsub(' ', '_').to_sym)
end

Given /^a cookbook recipe that declares a resource called ([^ ]+) with the condition (.*)(in|outside) a loop$/ do |name,condition,is_loop|
  write_recipe %Q{
    #{'%w{rover fido}.each do |pet_name|' if is_loop == 'in'}
      execute #{name} do
        command "echo 'Feeding: \#{pet_name}'; touch '/tmp/\#{pet_name}'"
        #{condition.nil? ? 'not_if { ::File.exists?("/tmp/\#{pet_name}")}' : condition}
      end
    #{'end' if is_loop == 'in'}
  }
end

Given /^a cookbook recipe that declares (a resource|multiple resources) nested in a ([a-z_]+) condition with (.*)$/ do |arity, wrapping_condition, condition_attribute|
  blk = "{ File.exists?('/etc/passwd') }"
  str = "'test -f /etc/passwd'"
  conds = wrapping_condition.split('_')
  write_recipe %Q{
    #{conds.first} node['foo'] == 'bar'
      service "apache" do
        action :enable
        #{
          case condition_attribute
            when /(only_if|not_if) block/ then "#{$1} #{blk}"
            when /(only_if|not_if) string/ then "#{$1} #{str}"
          end
        }
      end
      #{%q{service "httpd" do
        action :enable
      end} if arity.include?('multiple')}
    #{"elsif true\nlog 'bar'" if conds.include? 'elsif'}
    #{"else\nlog 'foo'" if conds.include? 'else'}
    end
  }
end

Given /^a cookbook recipe that declares a resource with a (.*)$/ do |conditional|
  write_recipe %Q{
    template "/tmp/foo" do
      mode "0644"
      source "foo.erb"
      #{conditional}
    end
  }
end

Given /^a cookbook recipe (?:that declares a resource with no conditions at all|with no notifications)$/ do
  write_recipe %q{
    service "apache" do
      action :enable
    end
  }
end

Given 'a cookbook recipe that declares multiple directories with different file modes' do
  write_recipe %q{
    directory "#{node["nagios"]["dir"]}/dist" do
      owner "nagios"
      group "nagios"
      mode 0755
    end

    directory node["nagios"]["state_dir"] do
      owner "nagios"
      group "nagios"
      mode 0751
    end

    directory "#{node["nagios"]["state_dir"]}/rw" do
      owner "nagios"
      group node["apache"]["user"]
      mode 2710
    end
  }
end

Given 'a cookbook recipe that declares multiple package resources mixed with other resources' do
  write_recipe %q{
    package "erlang-base" do
      action :install
    end
    package "erlang-corba" do
      action :install
    end
    package "erlang-crypto" do
      action :install
    end
    service "apache" do
      supports :restart => true, :reload => true
      action :enable
    end
    template "/tmp/somefile" do
      mode "0644"
      source "somefile.erb"
      not_if "test -f /etc/passwd"
    end
    package "rabbitmq-server" do
      action :install
    end
  }
end

Given /^a cookbook recipe that declares multiple (varying|non-varying) template resources within a block$/ do |vary|
   do_vary = vary == 'varying'
   write_recipe %Q{
     node['apps'].each do |app|
       template "/etc/#\{app\}.conf" do
         owner "root"
         group "root"
         #{'mode "0600"' if do_vary}
       end
       template "/etc/init.d/#\{app\}" do
         owner "root"
         group "root"
         #{'mode "0700"' if do_vary}
       end
       template "/home/#\{app\}/foo" do
         owner "root"
         group "root"
         #{'mode "0600"' if do_vary}
       end
     end
   }
end

Given 'a cookbook recipe that declares multiple resources varying only in the package name' do
  write_recipe %q{
    package "erlang-base" do
      action :install
    end
    package "erlang-corba" do
      action :install
    end
    package "erlang-crypto" do
      action :install
    end
    package "rabbitmq-server" do
      action :install
    end
  }
end

Given 'a cookbook recipe that declares multiple resources with more variation' do
  write_recipe %q{
    package "erlang-base" do
      action :install
    end
    package "erlang-corba" do
      action :install
    end
    package "erlang-crypto" do
      version '13.b.3'
      action :install
    end
    package "rabbitmq-server" do
      action :install
    end
  }
end

Given 'a cookbook recipe that declares non contiguous package resources mixed with other resources' do
  write_recipe %q{
    package "erlang-base" do
      action :install
    end
    service "apache" do
      supports :restart => true, :reload => true
      action :enable
    end
    package "erlang-crypto" do
      action :install
    end
    template "/tmp/somefile" do
      mode "0644"
      source "somefile.erb"
      not_if "test -f /etc/passwd"
    end
    package "rabbitmq-server" do
      action :install
    end
  }
end

Given 'a cookbook recipe that declares two or fewer resources varying only in the package name' do
  write_recipe %q{
    package "erlang-base" do
      action :install
    end
    package "erlang-corba" do
      action :install
    end
  }
end

Given 'a cookbook recipe that has a confusingly named local variable "default"' do
  write_recipe %q{
    default = {'run_list' => 'foo'}; Chef::Log.info default['run_list']
  }
end

Given 'a cookbook recipe that has a wrapping condition containing a resource with no condition attribute and a Ruby statement' do
  write_recipe %q{
    if node['foo'] == 'bar'
      Chef::Log.info "Enabling apache to start at boot"
      service "apache" do
        action :enable
      end
    end
  }
end

Given 'a cookbook recipe that has a wrapping condition containing a resource with no condition attribute within a loop' do
  write_recipe %q{
    unless node['bar'].include? 'something'
      bars.each do |bar|
        service bar['name'] do
          action :enable
        end
      end
    end
  }
end

Given /^a cookbook recipe that includes a local recipe(.*)$/ do |diff_name|
  cookbook = diff_name.empty? ? 'example' : 'foo'
  write_recipe %Q{
    include_recipe '#{cookbook}::server'
  }
  write_metadata %Q{
    name '#{cookbook}'
  }
end

Given /^a cookbook recipe that includes a recipe name from an( embedded)? expression(.*)$/ do |embedded, expr|
  if embedded
    write_recipe %Q{
      include_recipe "#{expr.strip}"
    }
  else
    write_recipe %q{
      include_recipe node['foo']['bar']
    }
  end
  write_metadata %q{
    depends "foo"
  }
end

Given /^a cookbook recipe that includes a(n un| )?declared recipe dependency(?: {0,1})(unscoped)?( with parentheses)?$/ do |undeclared,unscoped, parens|
  recipe_with_dependency(:is_declared => undeclared.strip.empty?,
                         :is_scoped => unscoped.nil?, :parentheses => parens)
end

Given 'a cookbook recipe that includes both declared and undeclared recipe dependencies' do
  write_recipe %q{
    include_recipe "foo::default"
    include_recipe "bar::default"
    file "/tmp/something" do
      action :delete
    end
    include_recipe "baz::default"
  }
  write_metadata %q{
    ['foo', 'bar'].each{|cbk| depends cbk}
  }
end

Given /^a cookbook recipe that includes several declared recipe dependencies - (brace|block)$/ do |brace_or_block|
  cookbook_declares_dependencies(brace_or_block.to_sym)
end

Given /a cookbook recipe that (install|upgrade)s (a gem|multiple gems)(.*)$/ do |action, arity, approach|
  if arity == 'a gem'
    if approach.empty?
      recipe_installs_gem(:simple, action.to_sym)
    else
      recipe_installs_gem(:compile_time, action.to_sym)
    end
  elsif approach.include? 'array'
    recipe_installs_gem(:compile_time_from_array, action.to_sym)
  else
    recipe_installs_gem(:compile_time_from_word_list, action.to_sym)
  end
end

Given 'a cookbook recipe that refers to a hidden template' do
  write_recipe %q{
    template '/etc/.s3cfg' do
      source '.s3cfg.erb'
    end
  }
  write_file "cookbooks/example/templates/default/.s3cfg.erb", %q{
    config=true
  }
end

Given /^a cookbook recipe that refers to a (missing |local )?template( in a subdirectory)?$/ do |missing_or_local, sub_dir|
  sub_dir = sub_dir ? 'sub_dir/' : ''
  write_recipe %Q{
    template "/tmp/config.conf" do
      #{'local true' if missing_or_local == 'local '}
      source "#{sub_dir}config.conf.erb"
      variables({
        :config_var => 'foo'
      })
    end
  }
  unless missing_or_local
    write_file "cookbooks/example/templates/default/#{sub_dir}config.conf.erb", %q{
      <%= @config_var %>
    }
  end
end

Given 'a cookbook recipe that refers to a template without an erb extension' do
  write_recipe %q{
    template '/etc/resolv.conf' do
      source 'resolv.conf'
    end
  }
  write_file 'cookbooks/example/templates/default/resolv.conf', ''
end

Given 'a cookbook recipe that defines a template where name is a complex expression' do
  write_recipe %q{
    template ::File.join(new_resource.foo.bar, "str", new_resource.baz) do
      variables({
        :config_var => 'foo'
      })
    end
  }
  write_file 'cookbooks/example/templates/default/barstrbaz.conf.erb', %q{
    <%= @config_var %>
  }
end

Given 'a cookbook recipe that defines a template where both the name and source are complex expressions' do
  write_recipe %q{
    template ::File.join(new_resource.foo.bar, "str", new_resource.baz) do
      source new_resource.foo.template
      variables({
        :config_var => 'foo'
      })
    end
  }
  write_file 'cookbooks/example/templates/default/barstrbaz.conf.erb', %q{
    <%= @config_var %>
  }
end


Given 'a cookbook recipe that defines a template where name and source are both simple expressions' do
  write_recipe %q{
    template "/tmp/config-#{foo}.conf" do
      source "config-#{foo}.erb"
      variables({
        :config_var => 'foo'
      })
    end
  }
  write_file 'cookbooks/example/templates/default/config-foo.conf.erb', %q{
    <%= @config_var %>
  }
end

Given /^a cookbook recipe that (refers to|infers) a template with an expression$/ do |type|
  write_attributes %q{
    default['foo']['name'] = 'foo'
  }
  write_recipe case type
    when 'infers'
      %q{
        template "/tmp/config-#{node['foo']['name']}.conf" do
          variables({
            :config_var => 'foo'
          })
        end
      }
    else
      %q{
        template "/tmp/config.conf" do
          source "config-#{node['foo']['name']}.erb"
          variables({
            :config_var => 'foo'
          })
        end
      }
  end
  write_file 'cookbooks/example/templates/default/config-foo.conf.erb', %q{
    <%= @config_var %>
  }
end

Given 'a cookbook recipe that uses a template from another cookbook' do
  write_recipe %q{
    template "foo" do
      cookbook "othercookbook"
      source "source_in_the_other_cookbook.erb"
    end
  }
end

Given /^a cookbook recipe that uses a(?:n)? (missing )?inferred template$/ do |missing|
  write_recipe %Q{
    template "/tmp/config.conf" do
      variables({
        :config_var => 'foo'
      })
    end
  }
  unless missing
    write_file 'cookbooks/example/templates/default/config.conf.erb', %q{
      <%= @config_var %>
    }
  end
end

Given /^a cookbook recipe that uses execute to (sleep and then )?([^ ]+) a service via (.*)$/ do |sleep, action, method|
  method = 'service' if method == 'the service command'
  recipe_controls_service(method.include?('full path') ? :service_full_path : method.gsub(/[^a-z_]/, '_').to_sym, sleep, action)
end

Given 'a cookbook recipe that uses execute to list a directory' do
  write_recipe %Q{
    execute "nothing-to-see-here" do
      command "ls"
      action :run
    end
  }
end

Given 'a cookbook recipe that uses execute with a name attribute to start a service' do
  write_recipe %Q{
    execute "/etc/init.d/foo start" do
      cwd "/tmp"
    end
  }
end

Given /^a cookbook recipe with a ([^ ]+) resource that subscribes to ([^ ]+) when notified by a remote_file$/ do |source, action|
  write_recipe %Q{
    #{source} "foo" do
      action :nothing
      subscribes :#{action}, resources(:remote_file => "/foo/bar"), :immediately
    end
  }
end

Given /^a cookbook recipe with a ([^ ]+) resource with action (.*)$/ do |resource, action|
  write_recipe %Q{
    #{resource} "foo" do
      action :#{action}
    end
  }
end

Given /^a cookbook recipe with a ([^ ]+) resource with actions (.*)$/ do |resource, actions|
  write_recipe %Q{
    #{resource} "foo" do
      action [#{actions.split(', ').map{|a| ":#{a}"}.join(", ")}]
    end
  }
end

Given 'a cookbook recipe with a case condition unrelated to platform' do
  write_recipe %Q{
    case day_of_week
      when "Monday", "Tuesday"
        package "foo" do
          action :install
        end
      when "Wednesday", "Thursday"
        package "bar" do
          action :install
      end
    end
  }.strip
end

Given /^a cookbook recipe with a resource that ([^ ]+)(?: )?([^ ]+)?$/ do |type,notification_timing|
  write_recipe %Q{
    template "/etc/foo.conf" do
      #{type} :restart, "service[foo]"#{", :#{notification_timing}" if notification_timing}
    end
  }
end

Given /^a cookbook recipe with a resource that (notifies|subscribes) a ([^ ]+) to ([^ ]+)$/ do |type, resource, action|
  notification = case type
    when 'notifies' then %Q{notifies :#{action}, "#{resource}[foo]"}
    when 'subscribes' then %Q{subscribes :#{action}, resources(:#{resource} => "foo")}
  end
  write_recipe %Q{
    template "/etc/apache.conf" do
      #{notification}
    end
  }
end

Given 'a cookbook recipe with a resource that uses the old notification syntax' do
  write_recipe %q{
    template "/etc/www/configures-apache.conf" do
      notifies :restart, resources(:service => "apache")
    end
  }
end

Given /^a cookbook recipe with a '([^']+)' condition for flavours (.*)$/ do |type,flavours|
  platforms = %Q{"#{flavours.split(',').join('","')}"}
  if type == 'case'
    @expected_line = 6
    write_recipe %Q{
      case node[:platform]
        when "debian", "ubuntu"
          package "foo" do
            action :install
          end
        when #{platforms}
          package "bar" do
            action :install
        end
      end
    }.strip
  elsif type == 'platform?'
    @expected_line = 1
    write_recipe %Q{
      if platform?(#{platforms})
        package "bar" do
          action :install
        end
      end
    }.strip
  else
    fail "Unrecognised type: #{type}"
  end
end

Given 'a cookbook recipe with a service resource that does not specify an action' do
  write_recipe %q{
    service "foo" do
      start_command "/sbin/service foo start"
    end
  }.strip
end

Given 'a cookbook recipe with a service resource with an action specified via a variable' do
  write_recipe %q{
    service "foo" do
      action action
    end
  }.strip
end

Given 'a cookbook recipe with multiple execute resources where the last uses git' do
  write_recipe %q{
    execute "one" do
      command "ls -al"
    end
    execute "two" do
      command "df -H"
    end
    execute "three" do
      command "git clone https://example.org/bar.git"
    end
  }.strip
end

Given 'a cookbook template that uses all variables passed' do
  write_recipe %q{
    template "/tmp/config.conf" do
      source "config.conf.erb"
      variables(
        :config_var => node[:configs][:config_var]
      )
    end
  }
  write_file 'cookbooks/example/templates/default/config.conf.erb', %q{
    <%= @config_var %>
  }
end

Given /^a cookbook that passes no variables to a template$/ do
  write_recipe %q{
    template "/tmp/config.conf" do
      source "config.conf.erb"
    end
  }
end

Given /^a cookbook that passes variables (.*) to a template with extension (.*)$/ do |vars, ext|
  write_recipe %Q{
    template "/tmp/config.conf" do
      source "config#{ext}"
      variables(
        :#{vars.split(',').map{|v| "#{v} => node[:#{v}]"}.join(",\n:")}
      )
    end
  }
end

Given /^a cookbook that passes variables (.*) to an inferred template$/ do |vars|
  write_recipe %Q{
    template "/tmp/config.conf" do
      variables(
        :#{vars.split(',').map{|v| "#{v} => node[:#{v}]"}.join(",\n:")}
      )
    end
  }
end

Given /^a cookbook that contains a (short|long) ruby block$/ do |length|
  recipe_with_ruby_block(length.to_sym)
end

Given 'a cookbook that contains a definition' do
  write_definition("apache_site", %q{
    define :apache_site, :enable => true do
      log "I am a definition"
    end
  })
  write_recipe %q{
    apache_site "default"
  }
end

Given /^a cookbook that contains a LWRP (?:with a single notification|that uses the current notification syntax)$/ do
  cookbook_with_lwrp({:notifies => :does_notify})
end

Given 'a cookbook that contains a LWRP with a single notification without parentheses' do
  cookbook_with_lwrp({:notifies => :does_notify_without_parens})
end

Given /^a cookbook that contains a LWRP that declares a resource called ([^ ]+) with the condition (.*)$/ do |name,condition|
  write_resource("site", %q{
    actions :create
    attribute :name, :name_attribute => true
  })
  write_provider("site", %Q{
    action :create do
      execute #{name} do
        command "echo 'Creating: \#{new_resource.name}'; touch '/tmp/\#{new_resource.name}'"
        #{condition}
      end
    end
  })
end

Given /^a cookbook that contains a LWRP that (?:does not trigger notifications|declares a resource with no condition)$/ do
  write_resource("site", %q{
    actions :create
    attribute :name, :kind_of => String, :name_attribute => true
  })
  write_provider("site", %q{
    action :create do
      log "Here is where I would create a site"
    end
  })
end

Given /^a cookbook that contains a LWRP that uses converge_by - (brace|do) block (with|without) parentheses$/ do |block_type, with_parens|
  write_resource("site", %q{
    actions :create
    attribute :name, :kind_of => String, :name_attribute => true
  })
  if block_type == 'brace'
    write_provider("site", %q{
      action :create do
        converge_by("Creating site #{new_resource.name}"){ Site.new(new_resource.name).create }
      end
    })
  else
    if with_parens == 'with'
      write_provider("site", %q{
        action :create do
          converge_by("Creating site #{new_resource.name}") do
            Site.new(new_resource.name).create
          end
        end
      })
    else
      write_provider("site", %q{
        action :create do
          converge_by "Creating site #{new_resource.name}" do
            Site.new(new_resource.name).create
          end
        end
      })
    end
  end
end

Given /^a cookbook that contains a LWRP that uses the deprecated notification syntax(.*)$/ do |qualifier|
  cookbook_with_lwrp({:notifies => qualifier.include?('class variable') ? :class_variable : :deprecated_syntax})
end

Given 'a cookbook that contains a LWRP that uses use_inline_resources' do
  cookbook_with_lwrp({:use_inline_resources => true})
end

Given 'a cookbook that contains a LWRP with multiple notifications' do
  write_resource("site", %q{
    actions :create, :delete
    attribute :name, :kind_of => String, :name_attribute => true
  })
  write_provider("site", %q{
    action :create do
      log "Here is where I would create a site"
      new_resource.updated_by_last_action(true)
    end
    action :delete do
      log "Here is where I would delete a site"
      new_resource.updated_by_last_action(true)
    end
  })
end

Given /^a cookbook that contains a LWRP with (no|a) default action( defined via a constructor)?$/ do |has_default_action,no_dsl|
  default_action = if has_default_action == 'no'
    :no_default_action
  elsif no_dsl.nil?
    :dsl_default_action
  else
    :ruby_default_action
  end
  cookbook_with_lwrp({:default_action => default_action,
                      :notifies => :does_notify})
end

Given 'a cookbook that contains no ruby blocks' do
  write_recipe %q{
    package "tar" do
      action :install
    end
  }
end

Given /^a cookbook that declares ([a-z]+) attributes via symbols$/ do |attribute_type|
  attributes_with_symbols(attribute_type)
end

Given /^a cookbook that does not contain a definition and has (no|a) definitions directory$/ do |has_dir|
  create_dir 'cookbooks/example/definitions/' unless has_dir == 'no'
  write_recipe %q{
    log "A defining characteristic of this cookbook is that it has no definitions"
  }
end

Given 'a cookbook that does not have a README at all' do
  write_recipe %q{
    log "Use the source luke"
  }
end

Given 'a cookbook that does not have defined metadata' do
  write_recipe %q{
    include_recipe "foo::default"
  }
end

Given /^a cookbook that downloads a file to (.*)$/ do |path|
  recipe_downloads_file({'/tmp' => :tmp_dir, '/tmp with an expression' => :tmp_dir_expr,
    'the Chef file cache' => :chef_file_cache_dir,
    'a users home directory' => :home_dir}[path])
end

Given /^a cookbook that has ([^ ]+) problems$/ do |problems|
  cookbook_that_matches_rules(
    problems.split(',').map do |problem|
      case problem
        when 'no ' then next
        when 'style' then 'FC002'
        when 'correctness' then 'FC006'
      end
    end
  )
end

Given 'a cookbook that has a README in markdown format' do
  write_recipe %q{
    log "Hello"
  }
  write_file 'cookbooks/example/README.md', %q{
    Description
    ===========

    Hi. This is markdown.
  }
end

Given 'a cookbook that has a README in RDoc format' do
  write_recipe %q{
    log "Hello"
  }
  write_file 'cookbooks/example/README.rdoc', %q{
    = DESCRIPTION:

    I used to be the preferred format but not any more (sniff).
  }
end

Given /^a cookbook that has maintainer metadata set to (.*) and ([^ ]+)$/ do |name,email|
  cookbook_with_maintainer(nil_if_unspecified(name), nil_if_unspecified(email))
end

Given 'a cookbook that has the default boilerplate metadata generated by knife' do
  cookbook_with_maintainer('YOUR_COMPANY_NAME', 'YOUR_EMAIL')
end

Given /^a cookbook that matches rules (.*)$/ do |rules|
  cookbook_that_matches_rules(rules.split(','))
end

Given 'a cookbook that matches that rule' do
  write_recipe %q{
    execute "bar" do
      action :run
    end
  }
end

Given /^a cookbook with a ([^ ]+) that (includes|does not include) a breakpoint$/ do |component,includes|
  content = case component
    when 'template' then includes == 'includes' ? "Hello <% require 'pry'; binding.pry %>" : 'Hello World'
    else includes == 'includes' ? 'binding.pry' : '# No breakpoint'
  end
  write_recipe ''
  case component
    when 'library' then write_library 'foo', content
    when 'metadata' then write_metadata content
    when 'provider' then write_provider 'foo', content
    when 'recipe' then write_recipe content
    when 'resource' then write_resource 'foo', content
    when 'template' then write_file 'cookbooks/example/templates/default/foo.erb',
      content
    else fail "Unrecognised component: #{component}"
  end
end

Given /^a cookbook with a single recipe for which the first hash (key|value) is an interpolated string$/ do |key_or_value|
  write_recipe case key_or_value
    when 'key' then %q{{"#{foo}" => 'bar', 'bar' => 'foo'}}
    when 'value' then %q{{'foo' => "#{bar}", 'bar' => 'foo'}}
  end
end

Given 'a cookbook with a single recipe that mixes node access types in an interpolated value' do
  write_recipe %q{
    execute "interpolated-example" do
      command "#{node['foo'][:bar]}'"
    end
  }
end

Given 'a cookbook with a single recipe that accesses multiple node attributes via symbols' do
  write_recipe %q{
    node[:foo] = 'bar'
    node[:testing] = 'bar'
  }
end

Given 'a cookbook with a single recipe that accesses nested node attributes via symbols' do
  write_recipe %q{node[:foo][:foo2] = 'bar'}
end

Given 'a cookbook with a single recipe that reads node attributes via symbols and quoted_symbols' do
  write_recipe %q{default[:foo][:'bar-baz']}
end

Given /^a cookbook with a single recipe that triggers FC019 with comment (.*)$/ do |comment|
  write_recipe %Q{
    file node[:bar] do
      content node['foo'] #{comment}
      action:create
    end
  }.strip
end

Given 'a cookbook with a single recipe that calls a patched node method' do
  write_library 'search', %q{
    class Chef
      class Node
        def in_tier?(*tier)
           tier.flatten.include?(node['tier'])
        end
      end
    end
  }
  write_recipe %q{
    if node['something']['bar'] || node.in_tier?('foof')
      Chef::Log.info("Node has been patched")
    end
  }
end

Given /^a cookbook with a single recipe that explicitly calls a node method( with multiple arguments)?$/ do |multi|
  write_recipe %Q{
    if node[:bar] and node.foo(#{multi ? 'bar, baz' : ''})
      Chef::Log.info('Explicit node method call should be ignored')
    end
  }
end

Given 'a cookbook with a single recipe that passes node attributes accessed via symbols to a template' do
  write_recipe %q{
    template "/etc/foo" do
      source "foo.erb"
      variables({
        :port => node[:foo][:port],
        :user => node[:foo][:user]
      })
    end
  }.strip
end

Given 'a cookbook with a single recipe that uses a hash value to access a node attribute' do
  write_recipe %q{
    some_hash = {
      :key => "value"
    }
    execute "accesses-hash" do
      command "echo #{node['foo'][some_hash[:key]]}"
    end
  }.strip
end

Given /a(nother)? cookbook with a single recipe that (reads|updates|ignores)(nested)? node attributes via ([a-z,]*)(?:(?: and calls node\.)?([a-z_?]+)?| with (.*)?)(?: only)?$/ do |more_than_one,op,nested,types,method,expr|
  cookbook_name = more_than_one.nil? ? 'example' : 'another_example'

  access = nested.nil? ? {:strings => "['foo']", :symbols => '[:foo]', :vivified => '.foo'} :
           {:strings => "['bar']['baz']", :symbols => '[:fee][:fi][:fo][:fum]', :vivified => '.bar.baz'}

  recipe_content =
      (if types == 'none'
        "log 'hello world'"
      elsif op == 'reads'
        types.split(',').map{|type| "log node#{access[type.to_sym]}"}.join("\n")
      else
        types.split(',').map{|type| "node#{access[type.to_sym]} = 'foo'"}.join("\n")
      end)

  recipe_content += "\n#{expr}"

  unless method.nil?
    recipe_content += {:platform? => "node.platform?('redhat')",
      :run_list => "log 'hello' if node.run_list.roles.include?(node[:foo][:bar])",
      :run_state => "node.run_state[:reboot_requested] = true",
      :set => "node.set['foo']['bar']['baz'] = 'secret'"}[method.to_sym]
  end

  write_recipe(recipe_content, cookbook_name)

end

Given 'a cookbook with a single recipe that searches based on a node attribute accessed via strings' do
  write_recipe %q{
    remote = search(:node, "name:#{node['drbd']['remote_host']}")[0]
  }.strip
end

Given 'a cookbook with a single recipe which accesses node attributes with symbols on lines 2 and 10' do
  write_recipe %q{
    # Here we access the node attributes via a symbol
    foo = node[:foo]

    directory "/tmp/foo" do
      owner "root"
      group "root"
      action :create
    end

    bar = node[:bar]
  }
end

Given 'a cookbook with a single recipe that assigns node attributes accessed via symbols to a local variable' do
  write_recipe %q{baz = node[:foo]}
end

Given /^a cookbook with a single recipe that creates a directory resource with (.*)$/ do |path_type|
  recipe_with_dir_path({'an interpolated name' => :interpolated_symbol,
                        'an interpolated name from a string' => :interpolated_string,
                        'a string literal' => :string_literal,
                        'a compound expression' => :compound_symbols,
                        'an interpolated variable and a literal' => :interpolated_symbol_and_literal,
                        'a literal and interpolated variable' => :literal_and_interpolated_symbol}[path_type])
end

Given 'a cookbook with a single recipe that searches but checks first (alternation) to see if this is server' do
  write_recipe %q{
    if Chef::Config[:solo] || we_dont_want_to_use_search
      # set up stuff from attributes
    else
      # set up stuff from search
      nodes = search(:node, "hostname:[* TO *] AND chef_environment:#{node.chef_environment}")
    end
  }
end

Given /^a cookbook with a single recipe that searches but checks first( \(string\))? to see if this is server$/ do |str|
  write_recipe %Q{
    if Chef::Config[#{str ? "'solo'" : ":solo"}]
      Chef::Log.warn("This recipe uses search. Chef Solo does not support search.")
    else
      nodes = search(:node, "hostname:[* TO *] AND chef_environment:#\{node.chef_environment\}")
    end
  }
end

Given 'a cookbook with a single recipe that searches but checks first (ternary) to see if this is server' do
  write_recipe %Q{
    required_node = Chef::Config[:solo] ? node : search(:node, query).first
  }
end

Given /^a cookbook with a single recipe that searches but checks with a negative first to see if this is server$/ do
  write_recipe %q{
    unless Chef::Config['solo']
      nodes = search(:node, "hostname:[* TO *]")
    else
      Chef::Log.warn("This recipe uses search. Chef Solo does not support search.")
    end
  }
end

Given /^a cookbook with a single recipe that searches but checks first \(method\) to see if this is server$/ do
  write_recipe %Q{
    if Chef::Config.solo
      Chef::Log.warn("This recipe uses search. Chef Solo does not support search.")
    else
      nodes = search(:node, "hostname:[* TO *] AND chef_environment:#\{node.chef_environment\}")
    end
  }
end

Given /^a cookbook with a single recipe that searches but returns first \((oneline|multiline)\) if search is not supported$/ do |format|
  if format == 'oneline'
    write_recipe %q{
      return Chef::Log.warn("This recipe uses search. Chef Solo does not support search.") if Chef::Config[:solo]
      nodes = search(:node, "hostname:[* TO *] AND chef_environment:#{node.chef_environment}")
    }
  else
    write_recipe %q{
      if Chef::Config[:solo]
        return Chef::Log.warn("This recipe uses search. Chef Solo does not support search.")
      end
      nodes = search(:node, "hostname:[* TO *] AND chef_environment:#{node.chef_environment}")
    }
  end
end

Given 'a cookbook with a single recipe that searches without checking if this is server' do
  write_recipe %q{nodes = search(:node, "hostname:[* TO *] AND chef_environment:#{node.chef_environment}")}
end

Given 'a cookbook with five recipes' do

end

Given /^a cookbook with metadata that declares a recipe with (.*)$/ do |declaration|
  write_metadata declaration
  write_recipe ""
end

Given /^a cookbook with metadata that (specifies|does not specify) the cookbook name$/ do |specifies|
  write_metadata %Q{
    #{"name 'example'" if specifies == 'specifies'}
  }
end

Given /^a directory that contains a role file ([^ ]+) in (json|ruby) that defines role name (.*)$/ do |file_name, format, role_name|
  role(:role_name => %Q{"#{role_name}"}, :file_name => file_name, :format => format.to_sym)
end

Given 'a directory that contains a ruby role that declares the role name more than once' do
  role(:role_name => ['"webserver"', '"apache"'], :file_name => 'webserver.rb')
end

Given 'a directory that contains a ruby role with an expression as its name' do
  role(:role_name => '"#{foo}#{bar}"', :file_name => 'webserver.rb')
end

Given /^a directory that contains an environment file (.*) in ruby that defines environment name (.*)$/ do |file_name, env_name|
  environment(:environment_name => %Q{"#{env_name}"}, :file_name => 'production.rb')
end

Given /^a ([a-z_]+) resource declared with the mode ([^\s]+)(?: with comment (.*)?)?$/ do |resource,mode,comment|
  recipe_resource_with_mode(resource, mode, comment)
end

Given 'a file resource declared without a mode' do
  write_recipe %q{
    file "/tmp/something" do
      action :delete
    end
  }
end

Given /^a file with multiple errors on one line(?: with comment (.*))?$/ do |comment|
  write_file "cookbooks/example/recipes/default.rb", %Q{node['run_state']['nginx_force_recompile'] = "\#{foo}"#{comment}}
end

Given(/^a LWRP with an action :create that notifies with (converge_by|updated_by_last_action) and another :delete that does not notify$/) do |notify_type|
  cookbook_with_lwrp_actions([
    {:name => :create, :notify_type => notify_type.to_sym},
    {:name => :delete, :notify_type => :none}
  ])
end

Given /^(?:a roles|an environments) directory$/ do

end

Given /^a Rakefile that defines (no lint task|a lint task with no block|a lint task with an empty block|a lint task with a block setting options to)(.*)?$/ do |task,options|
  rakefile(
    case task
      when /no block/ then :no_block
      when /empty block/ then :empty_block
      when /a block/ then :block
    end,
  options.strip.empty? ? {} : {:options => options.strip})
end

Given /^a Rakefile that defines a lint task specifying files to lint as (.*)$/ do |files|
  rakefile(:block, :files => files)
end

Given 'a Rakefile that defines a lint task specifying a different name' do
  rakefile(:block, :name => 'lint')
end

Given 'a recipe that contains a ruby block without a block attribute' do
  write_recipe %q{
    ruby_block "missing block" do
      puts "Missing a block attribute"
    end
  }
end

Given 'a recipe that contains both long and short ruby blocks' do
  recipe_with_ruby_block(:both)
end

Given /^a recipe that declares a ([^ ]+) resource with these attributes: (.*)$/ do |type,attributes|
  recipe_with_resource(type, attributes.split(','))
end

Given 'a recipe that declares a resource with an attribute value set to the result of a method call' do
  write_recipe %q{
    cron "run a command at a random minute" do
      user "root"
      minute rand(60)
      command "/usr/bin/whatever"
    end
  }
end

Given 'a recipe that declares a resource with only a name attribute' do
  write_recipe %q{
    package 'foo'
  }
end

Given 'a recipe that declares a resource with recognised attributes and a conditional execution ruby block' do
  write_recipe %q{
    file "/tmp/something" do
      owner "root"
      group "root"
      mode "0755"
      not_if do
        require 'foo'
        Foo.bar?(filename)
      end
      action :create
    end
  }
end

Given 'a recipe that declares a resource with recognised attributes and a nested block' do
  write_recipe %q{
    deploy_revision "foo" do
      revision "HEAD"
      repository "git://github.com/git/git.git"
      deploy_to "/foo"
      action :deploy
      before_migrate do
        execute "bundle install" do
          cwd release_path
          action :run
        end
      end
    end
  }
end

Given 'a recipe that declares a resource with standard attributes' do
  write_recipe %q{
    file "/tmp/something" do
      owner "root"
      group "root"
      mode "0755"
      action :create
    end
  }
end

Given 'a recipe that declares a user-defined resource' do
  write_recipe %q{
    apple "golden-delicious" do
      colour "yellow"
      action :consume
    end
  }
end

Given 'a recipe that declares multiple resources of the same type of which one has a bad attribute' do
  write_recipe %q{
    file "/tmp/something" do
      owner "root"
      group "root"
      mode "0755"
      action :create
    end
    file "/tmp/something" do
      punter "root"
      group "root"
      mode "0755"
      action :create
    end
    package "foo" do
      action :install
    end
  }
end

Given 'a resource declared with a guard within a loop with multiple block arguments' do
  write_recipe %q{
    {
    'foo' => 'bar',
    'baz' => 'bing',
    }.each do |foo, bar|
      package bar do
        not_if { node['foo'] == foo }
        action :install
      end
    end
  }
end

Given 'a resource that declares a guard containing a block' do
  write_recipe %q{
    template '/etc/foo' do
      not_if do
        s = false
        node['mylist'].each do |realm|
          s = node['mylist'][realm].empty?
          break if s
        end
        s
      end
      owner 'root'
      group 'root'
      mode '0644'
      source 'foo.erb'
    end
  }
end


Given 'a resource declared within a definition' do
  write_recipe %q{
    define :toto, {
    } do
      [:a, :b].each do |x|
        package x do
          not_if { node['foo'] == x }
          action :install
        end
      end
    end
  }
end

Given /^a rule that (declares|does not declare) a version constraint(?: of ([^ ]+)? to ([^ ]+)?)?$/ do |constraint, from, to|
  if from || to
    rule_with_version_constraint(from, to)
  else
    from_version = case constraint
      when /not/ then nil
      else '0.10.6'
    end
    rule_with_version_constraint(from_version, nil)
  end
end

Given /^a template that includes a partial( that includes the original template again)?$/ do |loops|
  write_recipe %q{
    template "/tmp/a" do
      source "a.erb"
      variables({
        :config_var => "foo"
      })
    end
  }
  write_file 'cookbooks/example/templates/default/a.erb', '<%= render "b.erb" %>'
  content = if loops
    '<%= render "a.erb" %>'
  else
    '<%= @config_var %>'
  end
  write_file 'cookbooks/example/templates/default/b.erb', content
end

Given /^a template that includes a (missing )?partial with a relative subdirectory path$/ do |missing|
  write_recipe %q{
    template "/tmp/a" do
      source "a.erb"
      variables({
        :config_var => "foo"
      })
    end
  }
  write_file 'cookbooks/example/templates/default/a.erb', '<%= render "partials/b.erb" %>'
  unless missing
    write_file 'cookbooks/example/templates/default/partials/b.erb', 'Partial content'
  end
end

Given 'access to the man page documentation' do

end

Given /^another cookbook that has (an older )?chef-solo-search installed$/ do |older|
  if older.nil?
    write_library 'search', %q{
      class Chef
        module Mixin
          module Language
            def search(bag_name, query=nil, sort=nil, start=0, rows=1000, &block)
              # https://github.com/edelight/chef-solo-search
            end
          end
        end
      end
    }
  else
    write_library 'search', %q{
      class Chef
        class Recipe
          def search(bag_name, query=nil, sort=nil, start=0, rows=1000, &block)
            # https://github.com/edelight/chef-solo-search
          end
        end
      end
    }
  end
end

Given 'I have installed the lint tool' do

end

Given 'metadata' do
  write_metadata %q{
    name 'example'
  }.strip
end

Given /^(?:a cookbook that has|the cookbook has) a Gemfile that includes rake and foodcritic$/ do
  buildable_gemfile
end

Given /^the current stable version of Chef (falls|does not fall) within it$/ do |falls_within|
  rule_with_version_constraint("98.10", nil) unless falls_within.include?('falls')
end

Given 'the gems have been vendored' do
  vendor_gems
end

Given 'the last role name declared does not match the containing filename' do

end

Given /^the inferred template contains the expression (.*)$/ do |expr|
  write_file "cookbooks/example/templates/default/config.conf.erb", %Q{
    <%= #{expr} %>
  }
end

Given /^the template (.+)?contains the expression (.*)$/ do |ext,expr|
  file = if ext
    "templates/default/config#{ext.strip}"
  else
    'templates/default/config.conf.erb'
  end
  write_file "cookbooks/example/#{file}", %Q{
    <%= #{expr} %>
  }
end

Given /^the template (.+)?contains partial includes of type (.*) with the expression (.*)$/ do |ext,type,expr|
  file = if ext
    "config#{ext.strip}"
  else
    'config.conf.erb'
  end
  if type == 'nested' and expr.split(',').length > 1
    expressions = expr.split(',')
    includes = (1..expressions.length).map{|i| "included_template_#{i}.erb"}
    (Array(file) + includes).zip(includes).map do |parent, child|
      content = if child
        "<%= render '#{child}' %>"
      else
        expressions.map{|e| "<%= #{e} %>"}.join("\n")
      end
      [parent, content]
    end.each do |template_name, content|
      write_file "cookbooks/example/templates/default/#{template_name}", content
    end
  else
    if type == 'no parentheses'
      include_string = "<%= render 'included_template.erb' %>"
    else
      include_string = "<%= render('included_template.erb') %>"
    end
    write_file "cookbooks/example/templates/default/#{file}", %Q{
      #{include_string}
    }
    write_file "cookbooks/example/templates/default/included_template.erb", %Q{
      <%= #{expr} %>
    }
  end
end

Given 'unit tests under a top-level test directory' do
  minitest_spec_attributes
end

Given 'a recipe that installs a gem with 5 retries' do
  write_recipe %q{
    gem_package "foo" do
      retries 5
      action :install
    end
  }
end

Given 'a recipe that installs a package with yum specifying the architecture' do
  write_recipe %q{
    yum_package "foo" do
      arch "x86_64"
      action :install
    end
  }
end

Given 'a recipe that reconfigures a package' do
  write_recipe %q{
    apt_package "foo" do
      action :reconfig
    end
  }
end

Given /^a recipe that uses require_recipe$/ do
  write_recipe %Q{
    require_recipe "foo::default"
  }
end

Given /^a recipe that uses include_recipe$/ do
  write_recipe %Q{
    include_recipe "foo::default"
  }
end

Given /^a ruby environment file that defines an environment with name (.*)$/ do |env_name|
  environment(:environment_name => %Q{"#{env_name}"}, :file_name => 'production.rb')
end

Given /^a ruby environment that triggers FC050 with comment (.*)$/ do |comment|
  write_file 'environments/production.rb', %Q{
    name "Production (eu-west-1)" #{comment}
    run_list "recipe[apache2]"
  }.strip
end

Given /^a ruby role file that defines a role with name (.*)$/ do |role_name|
  role(:role_name => [%Q{"#{role_name}"}], :file_name => 'webserver.rb')
end

Given /^a ruby role that triggers FC049 with comment (.*)$/ do |comment|
  write_file 'roles/webserver.rb', %Q{
    name "apache" #{comment}
    run_list "recipe[apache2]"
  }.strip
end

Given /^a template directory that contains a binary file (.*) that is not valid UTF-8$/ do |filename|
  template_dir = 'cookbooks/example/templates/default'
  write_recipe ''
  write_file "#{template_dir}/innocent_template.erb", '<%= hello %>'
  File.open("#{current_dir}/#{template_dir}/#{filename}", 'wb'){|f| f.putc(0x93)}
end

Given 'each role directory has a role with a name that does not match the containing file name' do
  role(:dir => 'roles1', :role_name => '"apache"', :file_name => 'webserver.rb')
  role(:dir => 'roles2', :role_name => '"postgresql"', :file_name => 'database.rb')
end

Given /^it contains an environment file (.*\.rb) that defines the environment name (.*)$/ do |file_name, env_name|
  environment(:environment_name => env_name, :file_name => file_name)
end

Given /^it contains a role file ([a-z]+\.rb) that defines the role name (.*)$/ do |file_name, role_name|
  role(:role_name => role_name, :file_name => file_name)
end

Given /^the cookbook metadata declares support for (.*)$/ do |supported_platforms|
  write_metadata(supported_platforms.split(',').map do |platform|
    "supports '#{platform}'"
  end.join("\n"))
end

Given 'the cookbook metadata declares support with versions specified' do
  write_metadata %q{
    supports 'redhat', '>= 6'
    supports 'scientific', '>= 6'
  }.strip
end

Given 'three of the recipes read node attributes via strings' do
  (1..3).map{|i| "string_#{i}"}.each do |recipe|
    write_file "cookbooks/example/recipes/#{recipe}.rb", "Chef::Log.warn node['foo']"
  end
end

Given 'two of the recipes read node attributes via symbols' do
  (1..2).map{|i| "symbol_#{i}"}.each do |recipe|
    write_file "cookbooks/example/recipes/#{recipe}.rb", "Chef::Log.warn node[:foo]"
  end
end

Given 'two roles directories' do

end

When /^I check the cookbook specifying ([^ ]+) as the Chef version$/ do |version|
  options = ['-c', version, 'cookbooks/example']
  in_current_dir do
    options = ['-I', 'rules/test.rb'] + options if Dir.exists?('rules')
  end
  run_lint(options)
end

When /^I check the cookbook( tree)?(?: specifying tags(.*))?(, specifying that context should be shown)?$/ do |whole_tree, tags, context|
  options = tags.nil? ? [] : tags.split(' ')
  options += ['-C'] unless context.nil?
  run_lint(options + ["cookbooks/#{whole_tree.nil? ? 'example' : ''}"])
end

Given /^the cookbook directory has a \.foodcritic file specifying tags (.*)$/ do |tags|
  write_file "cookbooks/example/.foodcritic", tags
  run_lint(["cookbooks/example"])
end

When 'I check both cookbooks specified as arguments' do
  run_lint(["cookbooks/another_example", "cookbooks/example"])
end

When /^I check both cookbooks with the command-line (.*)$/ do |command_line|
  cmds = command_line.split(' ').map do |c|
    if c.end_with?('example')
      "cookbooks/#{c}"
    else
      c
    end
  end
  run_lint(cmds)
end

When 'I check both roles directories' do
  run_lint ['-R', 'roles1', '-R', 'roles2']
end

When 'I check the cookbooks, role and environment together' do
  run_lint([
    '-B', 'cookbooks/another_example', '-B', 'cookbooks/example',
    '-E', 'environments',
    '-R', 'roles'
  ])
end

When 'I check the cookbook without specifying a Chef version' do
  run_lint(['-I', 'rules/test.rb', 'cookbooks/example'])
end

When 'I check the environment directory' do
  run_lint ['-E', 'environments']
end

When 'I check the eu environment file only' do
  run_lint ['-E', 'environments/production_eu.rb']
end

When /^I check the cookbook( without)? excluding the ([^ ]+) directory$/ do |no_exclude, dir|
  options = no_exclude.nil? ? ['-X', dir] : []
  run_lint(options + ['cookbooks/example'])
end

When 'I check the recipe' do
  run_lint(["cookbooks/example/recipes/default.rb"])
end

When 'I compare the man page options against the usage options' do

end

When 'I check the role directory' do
  run_lint ['-R', 'roles']
end

When /^I check the role directory as a (default|cookbook|role) path$/ do |path_type|
  options = case path_type
    when 'default' then ['roles']
    when 'cookbook' then ['-B', 'roles']
    when 'role' then ['-R', 'roles']
  end
  run_lint(options)
end

When 'I check the webserver role only' do
  run_lint ['-R', 'roles/webserver.rb']
end

When 'I list the available build tasks' do
  list_available_build_tasks
end

When /^I run it on the command line including a custom rule (file|directory) containing a rule that matches$/ do |path_type|
  write_file 'rules/custom_rules.rb', %q{
      rule "BAR001", "Use symbols in preference to strings to access node attributes" do
        tags %w{style attributes}
        recipe do |ast|
          attribute_access(ast, :type => :string).map{|ar| match(ar)}
        end
      end
  }
  run_lint(['-I',
            path_type == 'file' ? 'rules/custom_rules.rb' : 'rules',
            'cookbooks/example'])
end

When /^I run it on the command line including a file which does not contain Ruby code$/ do
  write_file 'rules/invalid_rules.rb', 'echo "not ruby"'
  capture_error do
    run_lint(['-I', 'rules/invalid_rules.rb', 'cookbooks/example'])
  end
end

When /^I run it on the command line including a missing custom rule file$/ do
  capture_error do
    run_lint(['-I', 'rules/missing_rules.rb', 'cookbooks/example'])
  end
end

When 'I run it on the command line specifying a cookbook that does not exist' do
  run_lint(['no-such-cookbook'])
end

When /^I run it on the command line specifying a( role|n environment) directory that does not exist$/ do |type|
  if type.include?('role')
    run_lint(['-R', 'no-such-role-dir'])
  else
    run_lint(['-E', 'no-such-environment-dir'])
  end
end

When 'I run it on the command line with no arguments' do
  run_lint([])
end

When /^I run it on the command line with the (?:unimplemented |)([^ ]+) option( with an argument)?$/ do |option, with_argument|
  options = []
  if option.match(/\-\w$/)
    options << option
  else
    options << "--#{option}"
  end
  options << "cookbooks/example" unless with_argument.nil?
  run_lint(options)
end

When 'I run the build' do
  run_build
end

Then 'a warning for the custom rule should be displayed' do
  expect_output('BAR001: Use symbols in preference to strings to access node attributes: cookbooks/example/recipes/default.rb:1')
end

Then 'all options should be documented in the man page' do
  man_page_options.must_equal usage_options_for_diff
end

Then /^an? '([^']+)' error should be displayed$/ do |expected_error|
  last_error.must_include expected_error
end

Then 'the attribute consistency warning 019 should be shown for both of the recipes that use symbols' do
  expect_warning 'FC019', :file => 'recipes/symbol_1.rb'
  expect_warning 'FC019', :file => 'recipes/symbol_2.rb'
end

Then /^the bare attribute keys warning 044 should not be displayed against the (brace|do) block$/ do |block_type|
  line = block_type == 'brace' ? 2 : 3
  expect_warning 'FC044', {:expect_warning => false, :line => line, :file_type => :attributes}
end

Then /^the bare attribute keys warning 044 should not be displayed against the (?:local variable|library call)$/ do
  expect_warning 'FC044', {:expect_warning => false, :line => 2, :file_type => :attributes}
end

Then 'the execute resource used to run git commands warning 040 should be displayed against the last resource' do
  expect_warning 'FC040', {:line => 7}
end

Then /^the LWRP does not notify when updated warning 017 should( not)? be shown against the :([^ ]+) action$/ do |not_shown, action|
  line = action == 'create' ? 1 : 8
  expect_warning('FC017', :file_type => :provider, :expect_warning => ! not_shown, :line => line)
end

Then /^the invalid (role|environment) name warning 050 should( not)? be shown$/ do |type, not_shown|
  file = type == 'role' ? 'roles/webserver.rb' : 'environments/production.rb'
  expect_warning 'FC050', {:expect_warning => ! not_shown, :file => file}
end

Then /^the invalid environment name warning 050 should( not)? be shown against the (eu|us) environment$/ do |not_shown, env|
  expect_warning 'FC050', {:expect_warning => ! not_shown,
    :file => "environments/production_#{env}.rb", :line => 1}
end

Then 'the prefer mixlib shellout warning 048 should not be displayed against the group resource' do
  expect_warning 'FC048', {:expect_warning => false, :line => 2}
end

Then /^the role name does not match file name warning 049 should( not)? be shown( against the second name)?$/ do |not_shown, second|
  expect_warning 'FC049', {:expect_warning => ! not_shown,
                           :file => 'roles/webserver.rb', :line => second ? 2 : 1}
end

Then 'the role name does not match file name warning 049 should be shown against the files in both directories' do
  expect_warning 'FC049', {:file => "roles1/webserver.rb", :line => 1}
  expect_warning 'FC049', {:file => "roles2/database.rb", :line => 1}
end

Then /^the role name does not match file name warning 049 should( not)? be shown against the (webserver|database) role$/ do |not_shown, role|
  expect_warning 'FC049', {:expect_warning => ! not_shown,
                           :file => "roles/#{role}.rb", :line => 1}
end

Then 'the long ruby block warning 014 should be displayed against the long block only' do
  expect_warning 'FC014', {:expect_warning => false, :line => 1}
  expect_warning 'FC014', {:expect_warning => true, :line => 11}
end

Then /^the lint task will be listed( under the different name)?$/ do |diff_name|
  expected_name = diff_name ? 'lint' : 'foodcritic'
  build_tasks.must_include([expected_name, 'Lint Chef cookbooks'])
end

Then 'no error should have occurred' do
  assert_no_error_occurred
end

Then /^(no )?warnings will be displayed against the tests$/ do |no_display|
  if no_display.nil?
    assert_test_warnings
  else
    assert_no_test_warnings
  end
end

Then 'the attribute consistency warning 019 should warn on lines 2 and 10 in that order' do
  expected_warnings = [2, 10].map do |line|
    "FC019: Access node attributes in a consistent manner: cookbooks/example/recipes/default.rb:#{line}"
  end
  expect_output(expected_warnings.join("\n"))
end

Then 'the attribute consistency warning 019 should be displayed for the recipe' do
  expect_warning('FC019', :line => 2)
end

Then 'the attribute consistency warning 019 should not be displayed for the attributes' do
  expect_warning('FC019', :file_type => :attributes, :line => 1, :expect_warning => false)
end

Then /^the warning ([0-9]+ )?should (not )?be (?:displayed|shown)$/ do |warning,should_not|
  code = warning.nil? ? 'FCTEST001' : "FC#{warning.strip}"
  expect_warning code, {:expect_warning => should_not.nil?}
end

Then /^the (?:[a-zA-Z \-_]+) warning ([0-9]+) should (not )?be displayed(?: against the (attributes|libraries|definition|metadata|provider|resource|README.md|README.rdoc) file)?( below)?$/ do |code, no_display, file, warning_only|
  options = {}
  options[:expect_warning] = no_display != 'not '
  unless file.nil?
    if file.include?('.')
      options[:file] = file
    else
      options[:file_type] = file.to_sym
    end
  end
  options[:line] = 3 if code == '018' and options[:expect_warning]
  options[:line] = 2 if ['021', '022'].include?(code)
  options[:warning_only] = ! warning_only.nil?
  expect_warning("FC#{code}", options)
end

Then /^the attribute consistency warning 019 should be (shown|not shown)$/ do |show_warning|
  expect_warning('FC019', :line => nil, :expect_warning => show_warning == 'shown')
end

Then /^the boilerplate metadata warning 008 should warn on lines (.*)$/ do |lines_to_warn|
  if lines_to_warn.strip == ''
    expect_no_warning('FC008')
  else
    lines_to_warn.split(',').each{|line| expect_warning('FC008', :line => line, :file => 'metadata.rb')}
  end
end

Then /the build status should be (successful|failed)$/ do |build_outcome|
  build_outcome == 'successful' ? assert_no_error_occurred : assert_error_occurred
end

Then /^the build will (succeed|fail) with (?:no )?warnings(.*)$/ do |build_outcome, warnings|
  assert_build_result(build_outcome == 'succeed', warnings.gsub(' ', '').split(','))
end

Then 'the check for server warning 003 should not be displayed against the condition' do
  expect_warning("FC003", :line => nil, :expect_warning => false)
end

Then /^the check for server warning 003 should not be displayed against the search after the (.*) conditional$/ do |format|
  line = format == 'oneline' ? 2 : 4
  expect_warning("FC003", :line => line, :expect_warning => false)
end

Then 'the check for server warning 003 should not be displayed given we have checked' do
  expect_warning("FC003", :line => 4, :expect_warning => false)
end

Then /^the consider adding platform warning 024 should( not)? be shown$/ do |should_not|
  expect_warning('FC024', :line => should_not.nil? ? @expected_line : nil, :expect_warning => should_not.nil?)
end

Then /^the conditional block contains only string warning 026 should be (shown|not shown)$/ do |show_warning|
  expect_warning('FC026', :line => nil, :expect_warning => show_warning == 'shown')
end

Then /^the current version should( not)? be displayed$/ do |no_display|
  version_str = "foodcritic #{FoodCritic::VERSION}"
  if no_display.nil?
    expect_output(version_str)
  else
    expect_no_output(version_str)
  end
end

Then /^the debugger breakpoint warning 030 should be (not )?shown against the (.*)$/ do |should_not, component|
  filename = case component
    when 'library' then 'libraries/foo.rb'
    when 'metadata' then 'metadata.rb'
    when 'provider' then 'providers/foo.rb'
    when 'recipe' then 'recipes/default.rb'
    when 'resource' then 'resources/foo.rb'
    when 'template' then 'templates/default/foo.erb'
  end
  expect_warning('FC030', :line => nil, :expect_warning => should_not.nil?, :file => filename)
end

Then 'the dodgy resource condition warning 022 should not be shown' do
  expect_warning('FC022', {:line => nil, :expect_warning => false})
end

Then /^the warning (\d+) should be (valid|invalid)$/ do |code, valid|
  code = "FC#{code}"
  valid == 'valid' ? expect_no_warning(code) : expect_warning(code)
end

Then /^the incorrect platform usage warning 028 should be (not )?shown$/ do |should_not|
  expect_warning('FC028', :line => nil, :expect_warning => should_not.nil?)
end

Then /^the line number and line of code that triggered the warning(s)? should be displayed$/ do |multiple|
  if multiple.nil?
    expect_line_shown 1, "log node[:foo]"
  else
    expect_line_shown 1, "node[:foo] = 'bar'"
    expect_line_shown 2, "    node[:testing] = 'bar'"
  end
end

Then 'the missing template warning 033 should not be displayed against the template' do
  expect_warning('FC033', :line => 3, :expect_warning => false)
end

Then /^the no leading cookbook name warning 029 should be (not )?shown$/ do |should_not|
  expect_warning('FC029', :line => 1, :expect_warning => should_not.nil?, :file => 'metadata.rb')
end

Then 'the node access warning 001 should be displayed for each match' do
  expect_warning('FC001', :line => 1)
  expect_warning('FC001', :line => 2)
end

Then 'the node access warning 001 should be displayed against the variables' do
  expect_warning('FC001', :line => 4)
  expect_warning('FC001', :line => 5)
end

Then 'the node access warning 001 should be displayed twice for the same line' do
  expect_warning('FC001', :line => 1, :num_occurrences => 2)
end

Then 'the node access warning 001 should warn on lines 2 and 10 in that order' do
  expected_warnings = [2, 10].map do |line|
    "FC001: Use strings in preference to symbols to access node attributes: cookbooks/example/recipes/default.rb:#{line}"
  end
  expect_output(expected_warnings.join("\n"))
end

Then 'the node access warning 001 should be displayed for the recipe' do
  expect_warning('FC001')
end

Then 'the node access warning 001 should not be displayed for the attributes' do
  expect_warning("FC001", :file_type => :attributes, :line => 1, :expect_warning => false)
end

Then 'the prefer chef_gem to manual install warning 025 should be shown' do
  expect_warning('FC025', :line => nil)
end

Then 'the recipe filename should be displayed' do
  expect_output "cookbooks/example/recipes/default.rb"
end

Then /^the resource sets internal attribute warning 027 should be (not )?shown$/ do |should_not|
  expect_warning('FC027', :line => nil, :expect_warning => should_not.nil?)
end

Then /^the service resource warning 005 should( not)? be visible$/ do |dont_show|
  expect_warning('FC005', :line => dont_show ? 2 : 7, :expect_warning => ! dont_show)
end

Then /^the service resource warning 005 should( not)? be displayed against the first resource in the block$/ do |dont_show|
  expect_warning('FC005', :line => 2, :expect_warning => ! dont_show)
end

Then /^the service resource warning 005 should( not)? be shown$/ do |dont_show|
  expect_warning('FC005', :line => 2, :file_type => :provider,
                 :expect_warning => ! dont_show)
end

Then /^the simple usage text should be displayed along with a (non-)?zero exit code$/ do |non_zero|
  usage_displayed(non_zero.nil?)
end

Then /^the template partials loop indefinitely warning 051 should (not )?be displayed against the templates$/ do |not_shown|
  expect_warning('FC051', :file => 'templates/default/a.erb', :line => 1,
                 :expect_warning => ! not_shown)
  expect_warning('FC051', :file => 'templates/default/b.erb', :line => 1,
                 :expect_warning => ! not_shown)
end

Then 'the undeclared dependency warning 007 should be displayed only for the undeclared dependencies' do
  expect_warning("FC007", :file => 'recipes/default.rb', :line => 1, :expect_warning => false)
  expect_warning("FC007", :file => 'recipes/default.rb', :line => 2, :expect_warning => false)
  expect_warning("FC007", :file => 'recipes/default.rb', :line => 6, :expect_warning => true)
end

Then /^the unused template variables warning 034 should (not )?be displayed against the (?:inferred )?template(.*)?$/ do |not_shown, ext|
  file = if ext.empty?
    'templates/default/config.conf.erb'
  else
    "templates/default/config#{ext.strip}"
  end
  expect_warning('FC034', :file => file, :line => 1,
		 :expect_warning => ! not_shown)
end

Then /^the unrecognised attribute warning 009 should be (true|false)$/ do |shown|
  shown == 'true' ? expect_warning('FC009') : expect_no_warning('FC009')
end

Then 'the unrecognised attribute warning 009 should be displayed against the correct resource' do
  expect_warning('FC009', :line => 7)
end

Then 'the usage text should include an option for specifying tags that will fail the build' do
  expect_usage_option('f', 'epic-fail TAGS',
    "Fail the build based on tags. Use 'any' to fail on all warnings.")
end

Then /^the warnings shown should be (.*)$/ do |warnings|
  warnings.split(',').each {|warning| expect_warning(warning, :line => nil)}
end

When /^I check the cookbook specifying a search grammar that (does not exist|is not in treetop format|is a valid treetop grammar)$/ do |search_grammar|
  case search_grammar
    when 'is not in treetop format'
      write_file('search.treetop', 'I am not a valid treetop grammar')
    when 'is a valid treetop grammar'
      write_file('search.treetop', IO.read(FoodCritic::Chef::Search.new.chef_search_grammars.first))
  end
  run_lint(['--search-grammar', 'search.treetop', 'cookbooks/example'])
end

Then /^the check should abort with an error$/ do
  assert_error_occurred
end

Given(/^a cookbook with an? (.*) file with an interpolated name$/) do |file_type|
  content = %q{
    a = "#{node.hostname}"
  }
  write_recipe content if file_type == "recipe"
  write_attributes content if file_type == "attribute"
  write_metadata content if file_type == "metadata"
  write_provider "site", content if file_type == "provider"
  write_resource "site", content if file_type == "resource"
  write_definition "apache_site", content if file_type == "definition"
  write_library "lib", content if file_type == "library"
end
