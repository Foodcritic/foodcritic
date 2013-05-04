Feature: Check for unused template variables

  In order to identify failure to parameterise template variables
  As a developer
  I want to identify variables passed to templates that are not used

  Scenario: All variables present in template
    Given a cookbook template that uses all variables passed
     When I check the cookbook
     Then the unused template variables warning 034 should not be displayed

  Scenario Outline: No variables passed
    Given a cookbook that passes no variables to a template
      And the template contains the expression <expression>
     When I check the cookbook
     Then the unused template variables warning 034 should not be displayed against the template
    Examples:
      | expression                  |
      | node[:configs][:config_var] |
      | @config_var                 |

  Scenario Outline: Variables passed
    Given a cookbook that passes variables <variables> to a template with extension <extension>
      And the template <extension> contains the expression <expression>
     When I check the cookbook
     Then the unused template variables warning 034 <displayed> be displayed against the template <extension>
    Examples:
      | variables              | expression                  | extension | displayed  |
      | config_var             | node[:configs][:config_var] | .conf.erb | should     |
      | config_var             | @config_var                 | .conf.erb | should not |
      | config_var             | @config_var['foo']          | .conf.erb | should not |
      | config_var             | node[:configs][:config_var] | .conf.erb | should     |
      | config_var,another_var | node[:configs][:config_var] | .conf.erb | should     |
      | config_var,another_var | @config_var                 | .conf.erb | should     |
      | config_var,another_var | @another_var                | .conf.erb | should     |
      | config_var             | @config_var                 | .conf     | should not |
      | config_var,another_var | @another_var                | .conf     | should     |
