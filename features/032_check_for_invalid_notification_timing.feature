Feature: Check for invalid notification timings

  In order to flag invalid notifications more quickly
  As a developer
  I want to identify notifications that have an invalid timing type

  Scenario Outline: Notification timings
    Given a cookbook recipe with a resource that <type> <notification_timing>
    When I check the cookbook
    Then the invalid notification timing warning 032 <display> be displayed
  Examples:
    | type       | notification_timing | display     |
    | notifies   |                     | should not  |
    | notifies   | immediately         | should not  |
    | notifies   | immediate           | should not  |
    | notifies   | delayed             | should not  |
    | notifies   | imediately          | should      |
    | subscribes |                     | should not  |
    | subscribes | immediately         | should not  |
    | subscribes | immediate           | should not  |
    | subscribes | delayed             | should not  |
    | subscribes | imediately          | should      |
