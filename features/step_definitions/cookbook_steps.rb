Given /^a ([a-z_])+ resource declared with the mode (.*)$/ do |resource,mode|
  recipe_resource_with_mode(resource, mode)
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

Given 'a cookbook recipe that declares a resource with no conditions at all' do
  write_recipe %q{
    service "apache" do
      action :enable
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

Given /^a cookbook recipe that includes a recipe name from an( embedded)? expression$/ do |embedded|
  if embedded
    # deliberately not evaluated
    write_recipe %q{
      include_recipe "foo::#{node['foo']['fighter']}"
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

Given /^a cookbook recipe that includes a(n un| )?declared recipe dependency( unscoped)?$/ do |undeclared,unscoped|
  recipe_with_dependency(:is_declared => undeclared.strip.empty?, :is_scoped => unscoped.nil?)
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

Given /^a cookbook that contains a (short|long) ruby block$/ do |length|
  recipe_with_ruby_block(length == 'short')
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

Given /^a cookbook that contains a LWRP that uses the deprecated notification syntax(.*)$/ do |qualifier|
  cookbook_with_lwrp({:notifies => qualifier.include?('class variable') ? :class_variable : :deprecated_syntax})
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
  recipe_downloads_file({'/tmp' => :tmp_dir, 'the Chef file cache' => :chef_file_cache_dir,
                         'a users home directory' => :home_dir}[path])
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

Given 'a cookbook with a single recipe that accesses multiple node attributes via symbols' do
  write_recipe %q{
    node[:foo] = 'bar'
    node[:testing] = 'bar'
  }
end

Given 'a cookbook with a single recipe that accesses nested node attributes via symbols' do
  write_recipe %q{node[:foo][:foo2] = 'bar'}
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

Given 'a cookbook with a single recipe that searches but checks first to see if this is server' do
  write_recipe %q{
    if Chef::Config[:solo]
      Chef::Log.warn("This recipe uses search. Chef Solo does not support search.")
    else
      nodes = search(:node, "hostname:[* TO *] AND chef_environment:#{node.chef_environment}")
    end
  }
end

Given 'a cookbook with a single recipe that searches without checking if this is server' do
  write_recipe %q{nodes = search(:node, "hostname:[* TO *] AND chef_environment:#{node.chef_environment}")}
end

Given 'a file resource declared without a mode' do
  write_recipe %q{
    file "/tmp/something" do
      action :delete
    end
  }
end

Given /^a recipe that declares a ([^ ]+) resource with these attributes: (.*)$/ do |type,attributes|
  recipe_with_resource(type, attributes.split(','))
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

Given 'I have started the lint tool with the REPL enabled' do
  @repl_match_string = 'Here is a placeholder recipe'
  write_recipe %Q{
    log "#{@repl_match_string}"
  }
end

When /^I check the cookbook( tree)?(?: specifying tags(.*))?(, specifying that context should be shown)?$/ do |whole_tree, tags, context|
  options = tags.nil? ? [] : tags.split(' ')
  options += ['-C'] unless context.nil?
  run_lint(options + ["cookbooks/#{whole_tree.nil? ? 'example' : ''}"])
end

When /^I define a new rule( and reset the list of rules| that includes a binding)?$/ do |qualifier|
  @rule_code, @rule_name = 'FC000', 'Like caprese and with the basil'
  repl_define_rule(@rule_code, @rule_name,
                  :reset_rules => ! /reset/.match(qualifier).nil?,
                  :with_binding => ! /binding/.match(qualifier).nil?,
                  :rule_match_string => @repl_match_string)
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

When 'I run it on the command line with no arguments' do
  run_lint([])
end

When /^I run it on the command line with the ([^ ]+) option$/ do |long_option|
  run_lint(["--#{long_option}"])
end

When 'I run it on the command line with the unimplemented verbose option' do
  run_lint(['-v'])
end

When 'I run it on the command line with too many arguments' do
  run_lint(['example', 'example'])
end

Then 'a warning for the custom rule should be displayed' do
  expect_output('BAR001: Use symbols in preference to strings to access node attributes: cookbooks/example/recipes/default.rb:1')
end

Then /^an? '([^']+)' error should be displayed$/ do |expected_error|
  last_error.should include expected_error
end

Then 'I should be able to see the AST from inside the rule' do
  repl_ast_available?(@repl_match_string).should be_true
end

Then 'I should be able to see the full list of DSL methods from inside the rule' do
  repl_api_methods.should == [
    :attribute_access,
    :checks_for_chef_solo?,
    :chef_dsl_methods,
    :chef_solo_search_supported?,
    :cookbook_name,
    :declared_dependencies,
    :file_match,
    :find_resources,
    :included_recipes,
    :literal_searches,
    :match,
    :os_command?,
    :read_ast,
    :resource_attribute,
    :resource_attribute?,
    :resource_attributes,
    :resource_attributes_by_type,
    :resource_name,
    :resource_type,
    :resources_by_type,
    :ruby_code?,
    :searches,
    :standard_cookbook_subdirs,
    :valid_query?
  ]
end

Then 'no error should have occurred' do
  assert_no_error_occurred
end

Then /^the (?:[a-zA-Z \-_]+) warning ([0-9]+) should (not )?be displayed(?: against the (attributes|definition|metadata|provider|resource|README.md|README.rdoc) file)?( below)?$/ do |code, no_display, file, warning_only|
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

Then /the build status should be (successful|failed)$/ do |build_status|
  build_status == 'successful' ? assert_no_error_occurred : assert_error_occurred
end

Then 'the check for server warning 003 should not be displayed given we have checked' do
  expect_warning("FC003", :line => 4, :expect_warning => false)
end

Then /^the consider adding platform warning 024 should( not)? be shown$/ do |should_not|
  expect_warning('FC024', :line => should_not.nil? ? @expected_line : nil, :expect_warning => should_not.nil?)
end

Then /^the conditional string looks like ruby warning 020 should be (shown|not shown)$/ do |show_warning|
  expect_warning('FC020', :line => nil, :expect_warning => show_warning == 'shown')
end

Then 'the current version should be displayed' do
  expect_output("foodcritic #{FoodCritic::VERSION}")
end

Then /^the file mode warning 006 should be (valid|invalid)$/ do |valid|
  valid == 'valid' ? expect_no_warning('FC006') : expect_warning('FC006')
end

Then /^the line number and line of code that triggered the warning(s)? should be displayed$/ do |multiple|
  if multiple.nil?
    expect_line_shown 1, "log node[:foo]"
  else
    expect_line_shown 1, "node[:foo] = 'bar'"
    expect_line_shown 2, "    node[:testing] = 'bar'"
  end
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

Then 'the prefer chef_gem to manual install warning 025 should be shown' do
  expect_warning('FC025', :line => nil)
end

Then 'the recipe filename should be displayed' do
  expect_output "cookbooks/example/recipes/default.rb"
end

Then 'the review should include the matching rules' do
  repl_review_includes_match?(@rule_code, @rule_name).should be_true
end

Then /^the rule should (not )?be visible in the list of rules$/ do |invisible|
  repl_rule_exists?(@rule_code, @rule_name).should == invisible.nil?
end

Then /^the service resource warning 005 should( not)? be visible$/ do |dont_show|
  expect_warning('FC005', :line => dont_show ? 2 : 7, :expect_warning => ! dont_show)
end

Then /^the service resource warning 005 should( not)? be shown$/ do |dont_show|
  expect_warning('FC005', :line => 2, :file_type => :provider,
                 :expect_warning => ! dont_show)
end

Then /^the simple usage text should be displayed along with a (non-)?zero exit code$/ do |non_zero|
  usage_displayed(non_zero.nil?)
end

Then 'the undeclared dependency warning 007 should be displayed only for the undeclared dependencies' do
  expect_warning("FC007", :file => 'recipes/default.rb', :line => 1, :expect_warning => false)
  expect_warning("FC007", :file => 'recipes/default.rb', :line => 2, :expect_warning => false)
  expect_warning("FC007", :file => 'recipes/default.rb', :line => 6, :expect_warning => true)
end

Then /^the unrecognised attribute warning 009 should be (true|false)$/ do |shown|
  shown == 'true' ? expect_warning('FC009') : expect_no_warning('FC009')
end

Then 'the unrecognised attribute warning 009 should be displayed against the correct resource' do
  expect_warning('FC009', :line => 7)
end

Then 'the usage text should include an option for launching a REPL' do
  expect_usage_option('r', '[no-]repl', 'Drop into a REPL for interactive rule editing.')
end

Then 'the usage text should include an option for specifying tags that will fail the build' do
  expect_usage_option('f', 'epic-fail TAGS', 'Fail the build if any of the specified tags are matched.')
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
