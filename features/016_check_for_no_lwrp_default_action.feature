Feature: Check for no LWRP default action

  In order to avoid wondering why a LWRP is not taking action
  As a developer
  I want to identify when a LWRP does not declare a default action

  Scenario: LWRP with no default action
    Given a cookbook that contains a LWRP with no default action
    When I check the cookbook
    Then the LWRP has no default action warning 016 should be displayed against the resource file

  Scenario: LWRP with a default action
    Given a cookbook that contains a LWRP with a default action
    When I check the cookbook
    Then the LWRP has no default action warning 016 should not be displayed against the resource file

  Scenario: LWRP with a default action (pre-DSL)
    Given a cookbook that contains a LWRP with a default action defined via a constructor
    When I check the cookbook
    Then the LWRP has no default action warning 016 should not be displayed against the resource file
