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
    Given a cookbook that contains a LWRP that uses converge_by - <block_type> block <with_parens> parentheses
    When I check the cookbook
    Then the LWRP does not notify when updated warning 017 should not be displayed against the provider file
  Examples:
    | block_type | with_parens |
    | brace      | with        |
    | do         | with        |
    | do         | without     |

  Scenario: LWRP using use_inline_resources
    Given a cookbook that contains a LWRP that uses use_inline_resources
     When I check the cookbook
     Then the LWRP does not notify when updated warning 017 should not be displayed against the provider file

  Scenario Outline: Warnings raised for actions individually
    Given a LWRP with an action :create that notifies with <notify_type> and another :delete that does not notify
    When I check the cookbook
    Then the LWRP does not notify when updated warning 017 should not be shown against the :create action
     And the LWRP does not notify when updated warning 017 should be shown against the :delete action
  Examples:
    | notify_type            |
    | converge_by            |
    | updated_by_last_action |
