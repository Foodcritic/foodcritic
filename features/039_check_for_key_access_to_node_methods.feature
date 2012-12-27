Feature: Check for key access to node methods

  In order to avoid failure at converge time
  As a developer
  I want to identify attempts to access node methods as attributes

  Scenario Outline: Resource actions
    Given a cookbook recipe that refers to <node_access>
    When I check the cookbook
    Then the node method cannot be accessed with key warning 039 <display> be displayed
  Examples:
    | node_access              | display    |
    | node['foo']              | should not |
    | node[:foo]               | should not |
    | node.foo                 | should not |
    | node.chef_environment    | should not |
    | node[:chef_environment]  | should     |
    | node['chef_environment'] | should     |
    | node.run_state['foo']    | should not |
    | node.run_state[:foo]     | should not |
    | node.run_state.foo       | should not |
    | node['run_state']['foo'] | should     |
    | node[:run_state][:foo]   | should     |
    | node['foo']['run_state'] | should not |
    | node[:foo][:run_state]   | should not |
    | node['tags']             | should not |
    | node[:tags]              | should not |
    | node.tags                | should not |

  Scenario: Expressions that look like node access
    Given a cookbook recipe that has a confusingly named local variable "default"
    When I check the cookbook
    Then the node method cannot be accessed with key warning 039 should not be displayed
