Feature: Check for resource repetition

  In order to write my recipe without being needlessly verbose
  As a developer
  I want to identify resources that vary minimally so I can reduce copy and paste

  Scenario: Package resource varying only a single attribute
    Given a cookbook recipe that declares multiple resources varying only in the package name
    When I check the cookbook
    Then the service resource warning 005 should be displayed

  Scenario: Package resource varying only a single attribute for a small number of resources
    Given a cookbook recipe that declares two or fewer resources varying only in the package name
    When I check the cookbook
    Then the service resource warning 005 should not be displayed

  Scenario: Package resource varying multiple attributes
    Given a cookbook recipe that declares multiple resources with more variation
    When I check the cookbook
    Then the service resource warning 005 should not be displayed

  Scenario: Non-varying packages mixed with other resources
    Given a cookbook recipe that declares multiple package resources mixed with other resources
    When I check the cookbook
    Then the service resource warning 005 should be displayed

  Scenario: Non-contiguous packages mixed with other resources
    Given a cookbook recipe that declares non contiguous package resources mixed with other resources
    When I check the cookbook
    Then the service resource warning 005 should not be displayed
