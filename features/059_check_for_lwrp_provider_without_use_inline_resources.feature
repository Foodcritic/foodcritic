Feature: Check for LWRP providers that do not declare use_inline_resources

  In order to ensure that notifications happen correctly
  As a cookbook provider author
  I want to always use_inline_resources

  Scenario: LWRP provider with use_inline_resources
    Given a cookbook that contains a LWRP provider with use_inline_resources
     When I check the cookbook
     Then the LWRP provider without use_inline_resources warning 059 should not be displayed against the provider file

  Scenario: LWRP provider without use_inline_resources
    Given a cookbook that contains a LWRP provider without use_inline_resources
     When I check the cookbook
     Then the LWRP provider without use_inline_resources warning 059 should be displayed against the provider file
