Given /^a ([a-z_])+ resource declared with the mode (.*)$/ do |resource,mode|
  recipe_resource_with_mode(resource, mode)
end

Given /^a cookbook recipe that attempts to perform a search with (.*)$/ do |search_type|
  recipe_with_search(search_type.include?('subexpression') ? :with_subexpression : search_type.gsub(' ', '_').to_sym)
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

Given 'a cookbook recipe that declares multiple package resources mixed with other resources' do
  write_recipe %q{
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

Given 'a cookbook recipe that includes a local recipe' do
  write_recipe %q{
    include_recipe 'example::server'
  }
  write_metadata %q{
    name 'example'
  }
end

Given 'a cookbook recipe that includes a recipe name from an expression' do
  # deliberately not evaluated
  write_recipe %q{
    include_recipe "foo::#{node['foo']['fighter']}"
  }
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

Given /^a cookbook recipe that uses execute to (sleep and then )?start a service via (.*)$/ do |sleep, method|
  method = 'service' if method == 'the service command'
  recipe_starts_service(method.include?('full path') ? :service_full_path : method.gsub(/[^a-z_]/, '_').to_sym, sleep)
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

Given 'a cookbook that contains a LWRP that does not trigger notifications' do
  write_resource("site", %q{
    actions :create
    attribute :name, :kind_of => String, :name_attribute => true
  })
  write_provider("site", %Q{
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

Given /^a cookbook that contains a LWRP with (no|a) default action$/ do |has_default_action|
  cookbook_with_lwrp({:default_action => has_default_action == 'no' ? :no_default_action : :ruby_default_action,
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

Given 'another cookbook that has chef-solo-search installed' do
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

Given 'I have installed the lint tool' do

end

Given 'I have started the lint tool with the REPL enabled' do
  @repl_match_string = 'Here is a placeholder recipe'
  write_recipe %Q{
    log "#{@repl_match_string}"
  }
end

When /^I check the cookbook( tree)?(?: specifying tags(.*))?$/ do |whole_tree, tags|
  run_lint((tags.nil? ? [] : tags.split(' ')) + ["cookbooks/#{whole_tree.nil? ? 'example' : ''}"])
end

When /^I define a new rule( and reset the list of rules| that includes a binding)?$/ do |qualifier|
  @rule_code, @rule_name = 'FC000', 'Like caprese and with the basil'
  repl_define_rule(@rule_code, @rule_name,
                  :reset_rules => ! /reset/.match(qualifier).nil?,
                  :with_binding => ! /binding/.match(qualifier).nil?,
                  :rule_match_string => @repl_match_string)
end

When 'I run it on the command line specifying a cookbook that does not exist' do
  run_lint(['no-such-cookbook'])
end

When 'I run it on the command line with no arguments' do
  run_lint([])
end

When 'I run it on the command line with the help option' do
  run_lint(['--help'])
end

When 'I run it on the command line with too many arguments' do
  run_lint(['example', 'example'])
end

Then 'I should be able to see the AST from inside the rule' do
  repl_ast_available?(@repl_match_string).should be_true
end

Then 'I should be able to see the list of helper DSL methods from inside the rule' do
  repl_helper_methods_available?.should be_true
end

Then 'no error should have occurred' do
  assert_no_error_occurred
end

Then /^the (?:[a-zA-Z \-]+) warning ([0-9]+) should (not )?be displayed(?: against the (attributes|definition|metadata|provider|README.md|README.rdoc) file)?$/ do |code, no_display, file|
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

Then /^the conditional string looks like ruby warning 020 should be (shown|not shown)$/ do |show_warning|
  expect_warning('FC020', :line => nil, :expect_warning => show_warning == 'shown')
end

Then /^the file mode warning 006 should be (valid|invalid)$/ do |valid|
  valid == 'valid' ? expect_no_warning('FC006') : expect_warning('FC006')
end

Then 'the node access warning 001 should be displayed for each match' do
  expect_warning('FC001', :line => 1)
  expect_warning('FC001', :line => 2)
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

Then 'the review should include the matching rules' do
  repl_review_includes_match?(@rule_code, @rule_name).should be_true
end

Then /^the rule should (not )?be visible in the list of rules$/ do |invisible|
  repl_rule_exists?(@rule_code, @rule_name).should == invisible.nil?
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