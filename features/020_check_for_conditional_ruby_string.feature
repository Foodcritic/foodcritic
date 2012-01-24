Feature: Check for conditional attributes that look like Ruby

  In order to prevent a Chef run from failing
  As a developer
  I want to identify conditional attributes that look like Ruby code but have been passed as a string

  Scenario Outline:
    Given a cookbook recipe that declares a resource with a <conditional_attribute>
    When I check the cookbook
    Then the conditional string looks like ruby warning 020 should be <show_warning>

  Examples:
    | conditional_attribute                                      | show_warning |
    | not_if { ::File.directory?(node[:foo]) }                   | not shown    |
    | not_if "::File.directory?(node[:foo])"                     | shown        |
    | not_if "rabbitmqctl list_vhosts \| grep /chef"             | not shown    |
    | not_if "test -L #{node['foo']['bar_dir']}/foo.xml"         | not shown    |
    | not_if "Dir.entries(node['foo']['bar']).length > 2"        | shown        |
    | only_if "test -f /foo/bar/baz/foo"                         | not shown    |
    | only_if do ::File.symlink?(node[:foo][:bar]) end           | not shown    |
    | only_if "::File.symlink?(node[:foo][:bar])"                | shown        |
    | only_if "foo --bar"                                        | not shown    |
    | not_if 'ls -1 \| grep foo'                                 | not shown    |
    | not_if '::File.directory?(node[:foo])'                     | shown        |
