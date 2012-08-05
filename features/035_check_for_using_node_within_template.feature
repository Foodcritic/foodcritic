Feature: Check for using node within template

  In order to cleanly separate node attributes from presentation
  As a developer
  I want to identify direct use of node attributes within templates

  Scenario Outline: Variables passed
    Given the template contains the expression <expression>
     When I check the cookbook
     Then the using node attribute directly warning 035 <displayed> be displayed against the template
    Examples:
      | expression                  | displayed  |
      | node[:configs][:config_var] | should     |
      | node.foo                    | should     |
      | node['foo']                 | should     |
      | node['foo']['bar']          | should     |
      | @config_var                 | should not |
