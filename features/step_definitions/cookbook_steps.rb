Given /^a cookbook with a single recipe that accesses node attributes via strings$/ do
  write_recipe %q{node['foo'] = 'bar'}
end

Given /^a cookbook with a single recipe that accesses multiple node attributes via strings$/ do
  write_recipe %q{node['foo'] = 'bar'
node['testing'] = 'bar'
  }
end

Given /^a cookbook with a single recipe that assigns node attributes accessed via strings to a local variable$/ do
  write_recipe %q{baz = node['foo']}
end

Given /^a cookbook with a single recipe that accesses nested node attributes via strings$/ do
  write_recipe %q{node['foo']['foo2'] = 'bar'}
end

Given /^a cookbook with a single recipe that accesses node attributes via symbols/ do
  write_recipe %q{node[:foo] = 'bar'}
end

Given /^a cookbook that declares ([a-z]+) attributes via strings$/ do |attribute_type|
  write_attributes %Q{#{attribute_type}["apache"]["dir"] = "/etc/apache2"}
end

When /^I check the cookbook$/ do
  run_lint
end

Then /^the (?:[a-z ]+) warning ([0-9]+) should be displayed( against the attributes file)?$/ do |code, atts|
  expect_warning("FC#{code}", atts.nil? ? {} : {:file => 'attributes/default.rb'})
end

Then /^the node access warning 001 should be displayed for each match$/ do
  expect_warning('FC001', :line => 1)
  expect_warning('FC001', :line => 2)
end

Then /^the node access warning 001 should be displayed twice for the same line$/ do
  expect_warning('FC001', :line => 1, :num_occurrences => 2)
end

Then /^the (?:[a-z ]+) warning ([0-9]+) should not be displayed$/ do |code|
  expect_no_warning("FC#{code}")
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

Given /^a cookbook with a single recipe that creates a directory resource with an interpolated literal and expression$/ do
  write_recipe %q{
    directory "#{node[:base_dir]}/sub_dir" do
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
          when method.include?('init.d')
            '/etc/init.d/foo start'
          when method.include?('full path')
            '/sbin/service foo start'
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

Given /^a cookbook recipe that uses execute to list a directory$/ do
  write_recipe %Q{
    execute "nothing-to-see-here" do
      command "ls"
      action :run
    end
  }.strip
end
