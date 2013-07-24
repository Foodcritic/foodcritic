Feature: Check for consistency in node access

  In order to be consistent in the way I access node attributes
  As a developer
  I want to identify if the same cookbook uses varying approaches to accessing node attributes

  Scenario Outline: Retrieve node attributes
    Given a cookbook with a single recipe that <accesses><nested> node attributes via <read_access_type>
    When I check the cookbook
    Then the attribute consistency warning 019 should be <show_warning>

    Examples:
      | accesses | read_access_type | nested | show_warning |
      | ignores  | none             |        | not shown    |
      | reads    | symbols          |        | not shown    |
      | reads    | strings          |        | not shown    |
      | reads    | vivified         |        | not shown    |
      | reads    | strings,symbols  |        | shown        |
      | reads    | strings,vivified |        | shown        |
      | reads    | symbols,strings  | nested | shown        |
      | reads    | symbols,vivified |        | shown        |
      | reads    | vivified,strings |        | shown        |
      | reads    | vivified,symbols |        | shown        |
      | updates  | symbols          |        | not shown    |
      | updates  | strings          | nested | not shown    |
      | updates  | vivified         |        | not shown    |
      | updates  | strings,symbols  |        | shown        |
      | updates  | strings,vivified | nested | shown        |
      | updates  | symbols,strings  |        | shown        |
      | updates  | symbols,vivified |        | shown        |
      | updates  | vivified,strings |        | shown        |
      | updates  | vivified,symbols |        | shown        |

  Scenario: Quoted symbols
    Given a cookbook with a single recipe that reads node attributes via symbols and quoted_symbols
    When I check the cookbook
    Then the attribute consistency warning 019 should be not shown

  Scenario: Multiple file matches
    Given a cookbook with five recipes
      And three of the recipes read node attributes via strings
      And two of the recipes read node attributes via symbols
     When I check the cookbook
     Then the attribute consistency warning 019 should be shown for both of the recipes that use symbols

  Scenario Outline: Ignore node built-in methods
    Given a cookbook with a single recipe that <accesses> node attributes via <read_access_type> and calls node.<method>
    When I check the cookbook
    Then the attribute consistency warning 019 should be <show_warning>

    Examples:
      | accesses | read_access_type | method    | show_warning |
      | reads    | strings          | platform? | not shown    |
      | reads    | symbols          | run_list  | not shown    |
      | reads    | symbols          | run_state | not shown    |
      | reads    | strings          | run_state | not shown    |
      | reads    | strings          | set       | not shown    |
      | reads    | strings,symbols  | set       | shown        |

  Scenario Outline: Ignore method calls on node values
    Given a cookbook with a single recipe that <accesses> node attributes via <read_access_type> with <expression>
    When I check the cookbook
    Then the attribute consistency warning 019 should be <show_warning>

    Examples:
      | accesses | read_access_type | expression                        | show_warning |
      | reads    | symbols          | node.platform_version             | shown        |
      | reads    | symbols          | node.run_list                     | not shown    |
      | reads    | symbols          | node[:foo].chomp                  | not shown    |
      | reads    | symbols          | node[:foo][:bar].split(' ').first | not shown    |
      | reads    | symbols          | node[:foo].bar                    | not shown    |
      | reads    | symbols          | foo = node[:foo].bar              | not shown    |
      | reads    | symbols          | node[:foo].each{\|f\| puts f}     | not shown    |
      | updates  | symbols          | node[:foo].strip                  | not shown    |
      | updates  | strings          | node[:foo].strip                  | shown        |
      | updates  | strings          | foo = node[:foo].strip            | shown        |
      | updates  | symbols          | node['foo'].strip                 | shown        |

  Scenario: Ignore method calls on patched node values
    Given a cookbook with a single recipe that calls a patched node method
     When I check the cookbook
     Then the attribute consistency warning 019 should be not shown

  Scenario: Ignore explicit method calls (zero-arg)
    Given a cookbook with a single recipe that explicitly calls a node method
     When I check the cookbook
     Then the attribute consistency warning 019 should be not shown

  Scenario: Ignore explicit method calls (multiple arguments)
    Given a cookbook with a single recipe that explicitly calls a node method with multiple arguments
     When I check the cookbook
     Then the attribute consistency warning 019 should be not shown

  Scenario: User hashes
    Given a cookbook with a single recipe that uses a hash value to access a node attribute
     When I check the cookbook
     Then the attribute consistency warning 019 should be not shown

  Scenario: Interpolated access
    Given a cookbook with a single recipe that mixes node access types in an interpolated value
      When I check the cookbook
     Then the attribute consistency warning 019 should be shown

  Scenario: Two cookbooks with differing approaches
    Given a cookbook with a single recipe that reads node attributes via strings only
      And another cookbook with a single recipe that reads node attributes via symbols only
     When I check the cookbook tree
    Then the attribute consistency warning 019 should not be displayed
