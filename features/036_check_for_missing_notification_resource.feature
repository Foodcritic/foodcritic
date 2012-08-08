Feature: Check for notified resources

  In order flag invalid notifications more quickly
  As a developer
  I want to identify notifications to resources that do not exist

  Scenario Outline: Notified resource
    Given a cookbook recipe with a resource that <type> using <syntax> syntax <notification_timing>
      And the resource is <present>
     When I check the cookbook
     Then the missing notified resource warning 036 <displayed> be displayed
    Examples:
      | type       | syntax    | notification_timing | present     | displayed  |
      | notifies   | old-style |                     | present     | should not |
      | notifies   | old-style |                     | not present | should     |
      | notifies   | old-style | immediately         | present     | should not |
      | notifies   | old-style | immediately         | not present | should     |
      | notifies   | old-style | delayed             | present     | should not |
      | notifies   | old-style | delayed             | not present | should     |
      | notifies   | new-style |                     | present     | should not |
      | notifies   | new-style |                     | not present | should     |
      | notifies   | new-style | immediately         | present     | should not |
      | notifies   | new-style | immediately         | not present | should     |
      | notifies   | new-style | delayed             | present     | should not |
      | notifies   | new-style | delayed             | not present | should     |

  Scenario: Notification resource name contains sub-expression
    Given a cookbook recipe with a resource that notifies where the name contains a sub-expression
      And the resource is present
     When I check the cookbook
     Then the missing notified resource warning 036 should not be displayed
