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

  Scenario: Execute resources branching
    Given a cookbook recipe that declares execute resources varying only in the command in branching conditionals
    When I check the cookbook
    Then the service resource warning 005 should not be visible

  Scenario: Execute resources branching - too many
    Given a cookbook recipe that declares too many execute resources varying only in the command in branching conditionals
    When I check the cookbook
    Then the service resource warning 005 should be visible

  Scenario: Execute resources branching in provider actions
    Given a cookbook provider that declares execute resources varying only in the command in separate actions
    When I check the cookbook
    Then the service resource warning 005 should not be shown

  Scenario: Execute resources in the same provider action
    Given a cookbook provider that declares execute resources varying only in the command in the same action
    When I check the cookbook
    Then the service resource warning 005 should be shown

  Scenario Outline: Template resources within a block
    Given a cookbook recipe that declares multiple <type> template resources within a block
    When I check the cookbook
    Then the service resource warning 005 should <show> against the first resource in the block
  Examples:
    | type        | show             |
    | varying     | not be displayed |
    | non-varying | be displayed     |

  Scenario: Directories with different file modes
    Given a cookbook recipe that declares multiple directories with different file modes
     When I check the cookbook
     Then the service resource warning 005 should not be displayed
