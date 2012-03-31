Feature: Check for condition around resource

  In order to express conditions in a idiomatic way
  As a developer
  I want to identify resources nested in a condition that would be better expressed as a conditional attribute

  Scenario: No conditions
    Given a cookbook recipe that declares a resource with no conditions at all
     When I check the cookbook
     Then the prefer conditional attributes warning 023 should not be displayed

  Scenario Outline: Resource wrapped in condition
    Given a cookbook recipe that declares a resource nested in a <wrapping_condition> condition with <condition_attribute>
     When I check the cookbook
     Then the prefer conditional attributes warning 023 <warning>

    Examples:
      | wrapping_condition | condition_attribute    | warning                 |
      | if                 | no condition attribute | should be displayed     |
      | unless             | no condition attribute | should be displayed     |
      | if_else            | no condition attribute | should not be displayed |
      | unless_else        | no condition attribute | should not be displayed |
      | if_elsif           | no condition attribute | should not be displayed |
      | if_elsif_else      | no condition attribute | should not be displayed |
      | if                 | only_if block          | should not be displayed |
      | if                 | only_if string         | should not be displayed |
      | unless             | only_if block          | should not be displayed |
      | unless             | only_if string         | should not be displayed |
      | if                 | not_if block           | should not be displayed |
      | if                 | not_if string          | should not be displayed |
      | unless             | not_if block           | should not be displayed |
      | unless             | not_if string          | should not be displayed |

  Scenario: Wrapped condition includes Ruby statements
    Given a cookbook recipe that has a wrapping condition containing a resource with no condition attribute and a Ruby statement
     When I check the cookbook
     Then the prefer conditional attributes warning 023 should not be displayed

  Scenario: Wrapped condition includes resource in a loop
    Given a cookbook recipe that has a wrapping condition containing a resource with no condition attribute within a loop
     When I check the cookbook
     Then the prefer conditional attributes warning 023 should not be displayed

  Scenario Outline: Multiple nested resources
    Given a cookbook recipe that declares multiple resources nested in a <wrapping_condition> condition with no condition attribute
     When I check the cookbook
     Then the prefer conditional attributes warning 023 should not be displayed

    Examples:
      | wrapping_condition |
      | if                 |
      | unless             |
