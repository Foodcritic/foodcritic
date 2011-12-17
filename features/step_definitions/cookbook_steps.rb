Given /^a cookbook with a single recipe that accesses node attributes via strings$/ do
  write_recipe %q{node['foo'] = 'bar'}
end

Given /^a cookbook with a single recipe that accesses multiple node attributes via symbols/ do
  write_recipe %q{
    node[:foo] = 'bar'
    node[:testing] = 'bar'
  }.strip
end

Given /^a cookbook with a single recipe that assigns node attributes accessed via symbols to a local variable$/ do
  write_recipe %q{baz = node[:foo]}
end

Given /^a cookbook with a single recipe that accesses nested node attributes via symbols/ do
  write_recipe %q{node[:foo][:foo2] = 'bar'}
end

Given /^a cookbook with a single recipe that accesses node attributes via symbols/ do
  write_recipe %q{node[:foo] = 'bar'}
end

Given /^a cookbook that declares ([a-z]+) attributes via symbols/ do |attribute_type|
  write_attributes %Q{#{attribute_type}[:apache][:dir] = "/etc/apache2"}
end

When /^I check the cookbook(?: specifying tags(.*))?$/ do |tags|
  run_lint(tags)
end

Then /^the (?:[a-zA-Z \-]+) warning ([0-9]+) should (not )?be displayed(?: against the (attributes|definition|metadata|provider|README.md|README.rdoc) file)?$/ do |code, no_display, file|
  options = {}
  options[:expect_warning] = no_display != 'not '

  file = 'metadata.rb' if file == 'metadata'
  file = 'attributes/default.rb' if file == 'attributes'
  file = 'definitions/apache_site.rb' if file == 'definition'
  file = 'providers/site.rb' if file == 'provider'
  options[:file] = "cookbooks/example/#{file}" unless file.nil?

  expect_warning("FC#{code}", options)
end

Then /^the node access warning 001 should be displayed for each match$/ do
  expect_warning('FC001', :line => 1)
  expect_warning('FC001', :line => 2)
end

Then /^the node access warning 001 should be displayed twice for the same line$/ do
  expect_warning('FC001', :line => 1, :num_occurrences => 2)
end

Given /^a cookbook with a single recipe that creates a directory resource with an interpolated name$/ do
  write_recipe %q{
    directory "#{node[:base_dir]}" do
      owner "root"
      group "root"
      mode "0755"
      action :create
    end
  }.strip
end

Given /^a cookbook with a single recipe that creates a directory resource with an interpolated name from a string$/ do
  write_recipe %q{
    directory "#{node['base_dir']}" do
      owner "root"
      group "root"
      mode "0755"
      action :create
    end
  }.strip
end

Given /^a cookbook with a single recipe that creates a directory resource with a string literal$/ do
  write_recipe %q{
    directory "/var/lib/foo" do
      owner "root"
      group "root"
      mode "0755"
      action :create
    end
  }.strip
end

Given /^a cookbook with a single recipe that creates a directory resource with a compound expression$/ do
  write_recipe %q{
    directory "#{node[:base_dir]}#{node[:sub_dir]}" do
      owner "root"
      group "root"
      mode "0755"
      action :create
    end
  }.strip
end

Given /^a cookbook with a single recipe that creates a directory resource with an interpolated variable and a literal$/ do
  write_recipe %q{
    directory "#{node[:base_dir]}/sub_dir" do
      owner "root"
      group "root"
      mode "0755"
      action :create
    end
  }.strip
end

Given /^a cookbook with a single recipe that creates a directory resource with a literal and interpolated variable$/ do
  write_recipe %q{
    directory "base_dir/#{node[:sub_dir]}" do
      owner "root"
      group "root"
      mode "0755"
      action :create
    end
  }.strip
end

Given /^a cookbook with a single recipe that searches without checking if this is server$/ do
  write_recipe %q{nodes = search(:node, "hostname:[* TO *] AND chef_environment:#{node.chef_environment}")}
end

Given /^a cookbook with a single recipe that searches but checks first to see if this is server$/ do
  write_recipe %q{
    if Chef::Config[:solo]
      Chef::Log.warn("This recipe uses search. Chef Solo does not support search.")
    else
      nodes = search(:node, "hostname:[* TO *] AND chef_environment:#{node.chef_environment}")
    end
  }.strip
end

Then /^the check for server warning 003 should not be displayed given we have checked$/ do
  expect_warning("FC004", :line => 4, :expect_warning => false)
end

Given /^a cookbook recipe that uses execute to (sleep and then )?start a service via (.*)$/ do |sleep, method|
  cmd = case
          when method == 'init.d'
            '/etc/init.d/foo start'
          when method.include?('full path')
            '/sbin/service foo start'
          when method == 'invoke-rc.d'
            'invoke-rc.d foo start'
          when method == 'upstart'
            'start foo'
          else
            'service foo start'
        end
  write_recipe %Q{
    execute "start-foo-service" do
      command "#{sleep.nil? ? '' : 'sleep 5; '}#{cmd}"
      action :run
    end
  }.strip
end

Given /^a cookbook recipe that uses execute with a name attribute to start a service$/ do
  write_recipe %Q{
    execute "/etc/init.d/foo start" do
      cwd "/tmp"
    end
  }.strip
end

Given /^a cookbook recipe that uses execute to list a directory$/ do
  write_recipe %Q{
    execute "nothing-to-see-here" do
      command "ls"
      action :run
    end
  }.strip
end

Given /^a cookbook recipe that declares multiple resources varying only in the package name$/ do
  write_recipe %Q{
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
  }.strip
end

Given /^a cookbook recipe that declares multiple resources with more variation$/ do
  write_recipe %Q{
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
  }.strip
end

Given /^a cookbook recipe that declares multiple package resources mixed with other resources$/ do
  write_recipe %Q{
    package "erlang-base" do
      action :install
    end
    package "erlang-corba" do
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
  }.strip
end

Given /^a ([a-z_])+ resource declared with the mode (.*)$/ do |resource,mode|
  source_att = resource == 'template' ? 'source "foo.erb"' : ''
  write_recipe %Q{
    #{resource} "/tmp/something" do
      #{source_att}
      owner "root"
      group "root"
      mode #{mode}
      action :create
    end
  }.strip
end

Given /^a file resource declared without a mode$/ do
  write_recipe %q{
    file "/tmp/something" do
      action :delete
    end
  }.strip
end

Then /^the file mode warning 006 should be (valid|invalid)$/ do |valid|
  if valid == 'valid'
    expect_no_warning('FC006')
  else
    expect_warning('FC006')
  end
end

Given /^a cookbook recipe that includes an undeclared recipe dependency( unscoped)?$/ do |unscoped|
  write_recipe %Q{
    include_recipe 'foo#{unscoped.nil? ? '::default' : ''}'
  }.strip
  write_metadata %q{
    version "1.9.0"
    depends "dogs", "> 1.0"
  }.strip
end

Given /^a cookbook recipe that includes a recipe name from an expression$/ do
  # deliberately not evaluated
  write_recipe %q{
    include_recipe "foo::#{node['foo']['fighter']}"
  }.strip
  write_metadata %q{
    depends "foo"
  }.strip
end

Given /^a cookbook recipe that includes a declared recipe dependency( unscoped)?$/ do |unscoped|
  write_recipe %Q{
    include_recipe 'foo#{unscoped.nil? ? '::default' : ''}'
  }.strip
  write_metadata %q{
    version "1.9.0"
    depends "foo"
  }.strip
end

Given /^a cookbook recipe that includes several declared recipe dependencies - (brace|block)$/ do |brace_or_block|
  write_recipe %q{
    include_recipe "foo::default"
    include_recipe "bar::default"
    include_recipe "baz::default"
  }.strip
  if brace_or_block == 'brace'
    write_metadata %q{
      %w{foo bar baz}.each{|cookbook| depends cookbook}
    }.strip
  else
    write_metadata %q{
      %w{foo bar baz}.each do |cb|
        depends cb
      end
    }.strip
  end
end

Given /^a cookbook recipe that includes both declared and undeclared recipe dependencies$/ do
  write_recipe %q{
    include_recipe "foo::default"
    include_recipe "bar::default"
    file "/tmp/something" do
      action :delete
    end
    include_recipe "baz::default"
  }.strip
  write_metadata %q{
    ['foo', 'bar'].each{|cbk| depends cbk}
  }.strip
end

Then /^the undeclared dependency warning 007 should be displayed only for the undeclared dependencies$/ do
  expect_warning("FC007", :file => 'cookbooks/example/metadata.rb', :line => 1, :expect_warning => false)
  expect_warning("FC007", :file => 'cookbooks/example/metadata.rb', :line => 2, :expect_warning => false)
  expect_warning("FC007", :file => 'cookbooks/example/metadata.rb', :line => 6, :expect_warning => true)
end

Given /^a cookbook recipe that includes a local recipe$/ do
  write_recipe %q{
    include_recipe 'example::server'
  }.strip
  write_metadata %q{
    name 'example'
  }.strip
end

Given /^a cookbook that does not have defined metadata$/ do
  write_recipe %q{
    include_recipe "foo::default"
  }.strip
end

Then /^no error should have occurred$/ do
  assert_exit_status(0)
end

Given /^a cookbook that has the default boilerplate metadata generated by knife$/ do
  write_recipe %q{
    #
    # Cookbook Name:: example
    # Recipe:: default
    #
    # Copyright 2011, YOUR_COMPANY_NAME
    #
    # All rights reserved - Do Not Redistribute
    #
  }.strip
  write_metadata %q{
    maintainer       "YOUR_COMPANY_NAME"
    maintainer_email "YOUR_EMAIL"
    license          "All rights reserved"
    description      "Installs/Configures example"
    long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
    version          "0.0.1"
  }.strip
end

Given /^a cookbook that has maintainer metadata set to (.*) and ([^ ]+)$/ do |maintainer,email|
  write_recipe %q{
    #
    # Cookbook Name:: example
    # Recipe:: default
    #
    # Copyright 2011, YOUR_COMPANY_NAME
    #
    # All rights reserved - Do Not Redistribute
    #
  }.strip

  fields = {}
  fields['maintainer'] = maintainer unless maintainer == 'unspecified'
  fields['maintainer_email'] = email unless email == 'unspecified'
  write_metadata %Q{
    #{fields.map{|field,value| %Q{#{field}\t"#{value}"}}.join("\n")}
    license          "All rights reserved"
    description      "Installs/Configures example"
    long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
    version          "0.0.1"
  }.strip
end

Then /^the boilerplate metadata warning 008 should warn on lines (.*)$/ do |lines_to_warn|
  if lines_to_warn.strip == ''
    expect_no_warning('FC008')
  else
    lines_to_warn.split(',').each{|line| expect_warning('FC008', :line => line, :file => 'cookbooks/example/metadata.rb')}
  end
end

Given /^a recipe that declares a ([^ ]+) resource with these attributes: (.*)$/ do |type,attributes|
  write_recipe %Q{
    #{type} "resource-name" do
      #{attributes.split(',').join(" 'foo'\n")} 'bar'
    end
  }.strip
end

Given /^a recipe that declares a resource with standard attributes$/ do
  write_recipe %q{
    file "/tmp/something" do
      owner "root"
      group "root"
      mode "0755"
      action :create
    end
  }.strip
end

Given /^a recipe that declares a user-defined resource$/ do
  write_recipe %q{
    apple "golden-delicious" do
      colour "yellow"
      action :consume
    end
  }.strip
end

Given /^a recipe that declares a resource with only a name attribute$/ do
  write_recipe %q{
    package 'foo'
  }.strip
end

Then /^the unrecognised attribute warning 009 should be (true|false)$/ do |shown|
  if shown == 'true'
    expect_warning('FC009')
  else
    expect_no_warning('FC009')
  end
end

Given /^a recipe that declares multiple resources of the same type of which one has a bad attribute$/ do
  write_recipe %q{
    file "/tmp/something" do
      owner "root"
      group "root"
      mode "0755"
      action :create
    end
    file "/tmp/something" do
      user "root"
      group "root"
      mode "0755"
      action :create
    end
    package "foo" do
      action :install
    end
  }.strip
end

Then /^the unrecognised attribute warning 009 should be displayed against the correct resource$/ do
  expect_warning('FC009', :line => 7)
end

Given /^a recipe that declares a resource with recognised attributes and a conditional execution ruby block$/ do
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
  }.strip
end

Given /^a cookbook recipe that attempts to perform a search with invalid syntax$/ do
  write_recipe %q{
    search(:node, 'run_list:recipe[foo::bar]') do |matching_node|
      puts matching_node.to_s
    end
  }.strip
end

Given /^a cookbook recipe that attempts to perform a search with valid syntax$/ do
  write_recipe %q{
    search(:node, 'run_list:recipe\[foo\:\:bar\]') do |matching_node|
      puts matching_node.to_s
    end
  }.strip
end

Given /^a cookbook recipe that attempts to perform a search with a subexpression$/ do
  write_recipe %q{
    search(:node, "roles:#{node['foo']['role']}") do |matching_node|
      puts matching_node.to_s
    end
  }.strip
end

Given /^a cookbook that matches rules (.*)$/ do |rules|
  recipe = ''
  rules.split(',').each do |rule|
    if rule == 'FC002'
      recipe += %q{
        directory "#{node['base_dir']}" do
          action :create
        end
      }
    elsif rule == 'FC003'
      recipe += %Q{nodes = search(:node, "hostname:[* TO *]")\n}
    elsif rule == 'FC004'
      recipe += %q{
        execute "stop-jetty" do
          command "/etc/init.d/jetty6 stop"
          action :run
        end
      }
    end
  end
  write_recipe(recipe.strip)
end

Then /^the warnings shown should be (.*)$/ do |warnings|
  warnings.split(',').each do |warning|
    expect_warning(warning, :line => nil)
  end
end

Given /^a cookbook that does not have a README at all$/ do
  write_recipe %q{
    log "Use the source luke"
  }.strip
end

Given /^a cookbook that has a README in markdown format$/ do
  write_recipe %q{
    log "Hello"
  }.strip
  write_file 'cookbooks/example/README.md', %q{
    Description
    ===========

    Hi. This is markdown.
  }.strip
end

Given /^a cookbook that has a README in RDoc format$/ do
  write_recipe %q{
    log "Hello"
  }.strip
  write_file 'cookbooks/example/README.rdoc', %q{
    = DESCRIPTION:

    I used to be the preferred format but not any more (sniff).
  }.strip
end

Given /^a cookbook that downloads a file to (.*)$/ do |path|
  download_path =
      case path
        when '/tmp' then '/tmp/large-file.tar.gz'
        when 'the Chef file cache' then '#{Chef::Config[:file_cache_path]}/large-file.tar.gz'
        when 'a users home directory' then '/home/ernie/large-file.tar.gz'
      end

  write_recipe %Q{
    remote_file "#{download_path}" do
      source "http://www.example.org/large-file.tar.gz"
    end
  }.strip
end

Given /^a cookbook that contains no ruby blocks$/ do
  write_recipe %q{
    package "tar" do
      action :install
    end
  }.strip
end

Given /^a cookbook that contains a (short|long) ruby block$/ do |length|
  if length == 'short'
    write_recipe %q{
      ruby_block "reload_client_config" do
        block do
          Chef::Config.from_file("/etc/chef/client.rb")
        end
        action :create
      end
    }.strip
  else
    write_recipe %q{
      ruby_block "too_long" do
        block do
          begin
            do_something('with argument')
            do_something_else('with another argument')
            foo = Foo.new('bar')
            foo.activate_turbo_boost
            foo.each do |thing|
              case thing
              when "fee"
                puts 'Fee'
              when "fi"
                puts 'Fi'
              when "fo"
                puts 'Fo'
              else
                puts "Fum"
              end
            end
          rescue Some::Exception
            Chef::Log.warn "Problem activating the turbo boost"
          end
        end
        action :create
      end
    }.strip
  end
end

Given /^a cookbook with a single recipe which accesses node attributes with symbols on lines 2 and 10$/ do
  write_recipe %q{
    # Here we access the node attributes via a symbol
    foo = node[:foo]

    directory "/tmp/foo" do
      owner "root"
      group "root"
      action :create
    end

    bar = node[:bar]
  }.strip
end

Then /^the node access warning 001 should warn on lines 2 and 10 in that order$/ do
  expected_warnings = [2, 10].map do |line|
    "FC001: Use strings in preference to symbols to access node attributes: cookbooks/example/recipes/default.rb:#{line}"
  end
  assert_partial_output(expected_warnings.join("\n"), all_output)
end

Given /^a cookbook that contains a definition$/ do
  write_definition("apache_site", %q{
    define :apache_site, :enable => true do
      log "I am a definition"
    end
  })
  write_recipe %q{
    apache_site "default"
  }.strip
end

Given /^a cookbook that does not contain a definition and has (no|a) definitions directory$/ do |has_dir|
  create_dir 'cookbooks/example/definitions/' unless has_dir == 'no'
  write_recipe %q{
    log "A defining characteristic of this cookbook is that it has no definitions"
  }.strip
end

Given /^a cookbook that contains a LWRP with (no|a) default action$/ do |has_default_action|
  write_resource("site", %q{
    actions :create
    attribute :name, :kind_of => String, :name_attribute => true
  }.strip)
  default_action = %q{
    def initialize(*args)
      super
      @action = :create
    end
  }.strip
  write_provider("site", %Q{
    action :create do
      log "Here is where I would create a site"
    end
    #{default_action unless has_default_action == 'no'}
  }.strip)
end

Given /^a cookbook that contains a LWRP that does not trigger notifications$/ do
  write_resource("site", %q{
    actions :create
    attribute :name, :kind_of => String, :name_attribute => true
  }.strip)
  write_provider("site", %Q{
    action :create do
      log "Here is where I would create a site"
    end
  }.strip)
end

Given /^a cookbook that contains a LWRP with a single notification$/ do
  write_resource("site", %q{
    actions :create
    attribute :name, :kind_of => String, :name_attribute => true
  }.strip)
  write_provider("site", %q{
    action :create do
      log "Here is where I would create a site"
      new_resource.updated_by_last_action(true)
    end
  }.strip)
end

Given /^a cookbook that contains a LWRP with multiple notifications$/ do
  write_resource("site", %q{
    actions :create, :delete
    attribute :name, :kind_of => String, :name_attribute => true
  }.strip)
  write_provider("site", %q{
    action :create do
      log "Here is where I would create a site"
      new_resource.updated_by_last_action(true)
    end
    action :delete do
      log "Here is where I would delete a site"
      new_resource.updated_by_last_action(true)
    end
  }.strip)
end