Feature: Check for invalid resource actions

  In order to avoid failure at converge time
  As a developer
  I want to identify resources that have an invalid action

  Scenario: Resource with default action
    Given a cookbook recipe with a service resource that does not specify an action
    When I check the cookbook
    Then the invalid resource action warning 038 should not be displayed

  Scenario: Resource with variable action
    Given a cookbook recipe with a service resource with an action specified via a variable
    When I check the cookbook
    Then the invalid resource action warning 038 should not be displayed

  Scenario Outline: Resource actions
    Given a cookbook recipe with a <resource> resource with action <action>
    When I check the cookbook
    Then the invalid resource action warning 038 <display> be displayed
  Examples:
    | resource | action  | display    |
    | service  | restart | should not |
    | service  | nothing | should not |
    | service  | none    | should     |
    | service  | create  | should     |
    | execute  | run     | should not |
    | execute  | go      | should     |
    | foo      | none    | should not |

  Scenario Outline: Multiple actions
    Given a cookbook recipe with a <resource> resource with actions <actions>
    When I check the cookbook
    Then the invalid resource action warning 038 <display> be displayed
  Examples:
    | resource | actions              | display    |
    | service  | enable, start        | should not |
    | service  | enble, start         | should     |
    | foo      | energize, revitalize | should not |

  Scenario Outline: Reconfigure a package
    Given a recipe that reconfigures a package
     When I check the cookbook specifying <version> as the Chef version
     Then the invalid resource action warning 038 <display> be displayed
  Examples:
    | version      | display    |
    | 0.9.2        | should     |
    | 0.10.0       | should     |
    | 0.10.6.beta3 | should not |
    | 0.10.6       | should not |
    | 11.4.0       | should not |
