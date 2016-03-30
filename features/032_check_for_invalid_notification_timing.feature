Feature: Check for invalid notification timings

  In order to flag invalid notifications more quickly
  As a developer
  I want to identify notifications that have an invalid timing type

  Scenario Outline: Notification timings
    Given a cookbook recipe with a resource that <type> <notification_timing>
    When I check the cookbook specifying <version> as the Chef version
    Then the invalid notification timing warning 032 <display> be displayed
  Examples:
    | type       | notification_timing | version | display     |
    | notifies   |                     | 12.6.0  | should not  |
    | notifies   | before              | 12.4.0  | should      |
    | notifies   | before              | 12.6.0  | should not  |
    | notifies   | immediately         | 12.6.0  | should not  |
    | notifies   | immediate           | 12.6.0  | should not  |
    | notifies   | delayed             | 12.6.0  | should not  |
    | notifies   | imediately          | 12.6.0  | should      |
    | subscribes |                     | 12.6.0  | should not  |
    | subscribes | before              | 12.4.0  | should      |
    | subscribes | before              | 12.6.0  | should not  |
    | subscribes | immediately         | 12.6.0  | should not  |
    | subscribes | immediate           | 12.6.0  | should not  |
    | subscribes | delayed             | 12.6.0  | should not  |
    | subscribes | imediately          | 12.6.0  | should      |
