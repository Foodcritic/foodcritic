Feature: Check for invalid notification actions

  In order to flag invalid notifications more quickly
  As a developer
  I want to identify notifications that have an action which is invalid for the notified resource

  Scenario Outline: Notification actions
    Given a cookbook recipe with a resource that <type> a <resource> to <action>
    When I check the cookbook
    Then the invalid notification action warning 037 <display> be displayed
  Examples:
    | type       | resource | action  | display    |
    | notifies   | service  | restart | should not |
    | notifies   | service  | nothing | should not |
    | notifies   | service  | create  | should     |
    | notifies   | execute  | run     | should not |
    | notifies   | execute  | execute | should     |
    | subscribes | service  | restart | should not |
    | subscribes | service  | nothing | should not |
    | subscribes | service  | create  | should     |
    | subscribes | execute  | run     | should not |
    | subscribes | execute  | execute | should     |
