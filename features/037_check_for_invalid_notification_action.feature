Feature: Check for invalid notification actions

  In order to flag invalid notifications more quickly
  As a developer
  I want to identify notifications that have an action which is invalid for the notified resource

  Scenario Outline: Notification actions
    Given a cookbook recipe with a resource that notifies a <resource> to <action>
    When I check the cookbook
    Then the invalid notification action warning 037 <display> be displayed
  Examples:
    | resource | action  | display    |
    | service  | restart | should not |
    | service  | nothing | should not |
    | service  | create  | should     |
    | execute  | run     | should not |
    | execute  | execute | should     |

  Scenario Outline: Subscription actions
    Given a cookbook recipe with a <source> resource that subscribes to <action> when notified by a remote_file
    When I check the cookbook
    Then the invalid notification action warning 037 <display> be displayed
  Examples:
    | source   | action  | display    |
    | service  | restart | should not |
    | service  | nothing | should not |
    | service  | create  | should     |
    | execute  | run     | should not |
    | execute  | execute | should     |

  Scenario: Notification action is an expression
    Given a cookbook recipe with a resource that notifies where the action is an expression
     When I check the cookbook
     Then the invalid notification action warning 037 should not be displayed
