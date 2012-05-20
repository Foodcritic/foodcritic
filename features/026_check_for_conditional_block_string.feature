Feature: Check for conditional attribute blocks with only strings

  In order to avoid wrongly actioning a resource
  As a developer
  I want to identify conditional attribute blocks that consist only of strings

  Scenario Outline:
    Given a cookbook recipe that declares a resource with a <conditional_attribute>
    When I check the cookbook
    Then the conditional block contains only string warning 026 should be <show_warning>

  Examples:
    | conditional_attribute                   | show_warning |
    | not_if { "ls foo" }                     | shown        |
    | not_if do "ls foo" end                  | shown        |
    | only_if { "ls #{node['foo']['path']}" } | shown        |
    | not_if { "ls #{foo.method()}" }         | shown        |
    | only_if { foo.bar }                     | not shown    |
    | not_if { foo.to_s }                     | not shown    |
    | not_if { File.exists?("/etc/foo") }     | not shown    |
