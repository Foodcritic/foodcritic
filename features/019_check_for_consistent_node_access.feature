Feature: Check for consistency in node access

  In order to be consistent in the way I access node attributes
  As a developer
  I want to identify if the same cookbook uses varying approaches to accessing node attributes

  Scenario Outline: Retrieve node attributes
    Given a cookbook with a single recipe that <accesses> node attributes via <read_access_type>
    When I check the cookbook
    Then the attribute consistency warning 019 should be <show_warning>

    Examples:
      | accesses | read_access_type | show_warning |
      | ignores  | none             | not shown    |
      | reads    | symbols          | not shown    |
      | reads    | strings          | not shown    |
      | reads    | vivified         | not shown    |
      | reads    | strings,symbols  | shown        |
      | reads    | strings,vivified | shown        |
      | reads    | symbols,strings  | shown        |
      | reads    | symbols,vivified | shown        |
      | reads    | vivified,strings | shown        |
      | reads    | vivified,symbols | shown        |
      | updates  | symbols          | not shown    |
      | updates  | strings          | not shown    |
      | updates  | vivified         | not shown    |
      | updates  | strings,symbols  | shown        |
      | updates  | strings,vivified | shown        |
      | updates  | symbols,strings  | shown        |
      | updates  | symbols,vivified | shown        |
      | updates  | vivified,strings | shown        |
      | updates  | vivified,symbols | shown        |

  Scenario: Two cookbooks with differing approaches
    Given a cookbook with a single recipe that reads node attributes via strings only
      And another cookbook with a single recipe that reads node attributes via symbols only
     When I check the cookbook tree
    Then the attribute consistency warning 019 should not be displayed
