Feature: Check for attribute assignment without specified precedence

  In order to ensure that my cookbooks continue to work with Chef 11+
  As a developer
  I want to identify node attribute assignment that does not specify the attribute precedence

  Scenario Outline: Attribute assignment
    Given a cookbook attributes file with assignment <assignment>
     When I check the cookbook
     Then the attribute assignment without precedence warning 047 <show_warning> be displayed against the attributes file
  Examples:
    | assignment                          | show_warning |
    | node[:foo] = 'bar'                  | should       |
    | node['foo'] = 'bar'                 | should       |
    | node['foo'] = a_var                 | should       |
    | a_var = node['foo']                 | should not   |
    | node['foo']['bar'] = 'baz'          | should       |
    | node['foo']['bar']['baz'] = 'fizz'  | should       |
    | node.foo = 'bar'                    | should       |
    | node.normal.foo = 'bar'             | should not   |
    | node.normal['foo'] = 'bar'          | should not   |
    | node.default['foo'] = 'bar'         | should not   |
    | node.force_default['foo'] = 'bar'   | should not   |
    | node.default!['foo'] = 'bar'        | should not   |
    | node.set['foo'] = 'bar'             | should not   |
    | node.override['foo'] = 'bar'        | should not   |
    | node.override!['foo'] = 'bar'       | should not   |
    | node.force_override['foo'] = 'bar'  | should not   |
    | node.automatic_attrs['foo'] = 'bar' | should not   |
    | node['foos'] << 'bar'               | should       |
    | node['foo']['bars'] << 'baz'        | should       |
    | foo = node['bar']                   | should not   |
    | baz << node['foo']['bars']          | should not   |
    | node.run_state['foo'] = bar         | should not   |
    | foo[:bar] << node['baz']            | should not   |
    | node.default['foo'] << bar          | should not   |
    | node.default_unless['foo'] = 'bar'  | should not   |
    | node.normal_unless['foo'] = 'bar'   | should not   |
    | node.set_unless['foo'] = 'bar'      | should not   |
    | node.override_unless['foo'] = 'bar' | should not   |

  Scenario Outline: Attribute assignment in recipe
    Given a cookbook recipe file with assignment <assignment>
     When I check the cookbook
     Then the attribute assignment without precedence warning 047 <show_warning> be displayed
  Examples:
    | assignment                 | show_warning |
    | node[:foo] = 'bar'         | should       |
    | node.normal['foo'] = 'bar' | should not   |
