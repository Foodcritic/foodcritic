Feature: Check for no LWRP notifications

  In order to ensure resource actions are triggered as expected
  As a developer
  I want to identify when a LWRP does not trigger notifications

  Scenario: LWRP with no notifications
    Given a cookbook that contains a LWRP that does not trigger notifications
    When I check the cookbook
    Then the LWRP does not notify when updated warning 017 should be displayed against the provider file

  Scenario: LWRP with a notification
    Given a cookbook that contains a LWRP with a single notification
    When I check the cookbook
    Then the LWRP does not notify when updated warning 017 should not be displayed against the provider file

  Scenario: LWRP with a notification without parentheses
    Given a cookbook that contains a LWRP with a single notification without parentheses
    When I check the cookbook
    Then the LWRP does not notify when updated warning 017 should not be displayed against the provider file

  Scenario: LWRP with multiple notifications
    Given a cookbook that contains a LWRP with multiple notifications
    When I check the cookbook
    Then the LWRP does not notify when updated warning 017 should not be displayed against the provider file

  Scenario Outline: LWRP using converge_by
    Given a cookbook that contains a LWRP that uses converge_by - <block_type> block
    When I check the cookbook
    Then the LWRP does not notify when updated warning 017 should not be displayed against the provider file
  Examples:
    | block_type |
    | brace      |
    | do         |

  Scenario: LWRP using use_inline_resources
    Given a cookbook that contains a LWRP that uses use_inline_resources
     When I check the cookbook
     Then the LWRP does not notify when updated warning 017 should not be displayed against the provider file
