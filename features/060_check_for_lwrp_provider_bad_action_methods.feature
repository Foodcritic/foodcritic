Feature: Check for LWRP providers that declare use_inline_resources and declare action_<name> methods

  In order to ensure that notifications happen correctly
  As a cookbook provider author
  I want to always use_inline_resources

  Scenario: LWRP provider with use_inline_resources and bad action_create
    Given a cookbook that contains a LWRP provider with use_inline_resources and uses def action_create
     When I check the cookbook
     Then the LWRP provider without use_inline_resources and bad action_create warning 060 should be displayed against the provider file on line 3

  Scenario: LWRP provider without use_inline_resources
    Given a cookbook that contains a LWRP provider without use_inline_resources
     When I check the cookbook
     Then the LWRP provider without use_inline_resources and bad action_create warning 060 should not be displayed against the provider file

  Scenario: LWRP provider without use_inline_resources and (okay) action_create
    Given a cookbook that contains a LWRP provider without use_inline_resources and uses def action_create
     When I check the cookbook
     Then the LWRP provider without use_inline_resources and bad action_create warning 060 should not be displayed against the provider file

  Scenario: LWRP provider with use_inline_resources
    Given a cookbook that contains a LWRP provider with use_inline_resources
     When I check the cookbook
     Then the LWRP provider without use_inline_resources and bad action_create warning 060 should not be displayed against the provider file
