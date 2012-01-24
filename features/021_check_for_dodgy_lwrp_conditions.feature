Feature: Check for dodgy provider conditions

  In order to ensure that resources are declared as intended within a resource provider
  As a developer
  I want to identify resources conditions that will be checked only for the first resource

  Scenario: Provider with no condition
    Given a cookbook that contains a LWRP that declares a resource with no condition
    When I check the cookbook
    Then the dodgy resource condition warning 021 should not be displayed against the provider file

  Scenario: Provider with re-used resource
    Given a cookbook that contains a LWRP that declares a resource with a condition that will only be evaluated once
    When I check the cookbook
    Then the dodgy resource condition warning 021 should be displayed against the provider file

  Scenario: Provider with separate resource
    Given a cookbook that contains a LWRP that declares a resource with a condition that will be evaluated for each resource
    When I check the cookbook
    Then the dodgy resource condition warning 021 should not be displayed against the provider file