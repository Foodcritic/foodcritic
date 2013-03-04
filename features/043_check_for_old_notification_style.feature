Feature: Check for old notification style

  In order to be able to notify a resource that has not yet been declared
  As a developer
  I want to use the new-style notification syntax

  Scenario: No notification
    Given a cookbook recipe with no notifications
     When I check the cookbook
     Then the prefer new notification syntax warning 043 should not be displayed

  Scenario: New-style notification
    Given a cookbook recipe with a resource that notifies a service to restart
     When I check the cookbook
     Then the prefer new notification syntax warning 043 should not be displayed

  Scenario: Old-style notification
    Given a cookbook recipe with a resource that uses the old notification syntax
     When I check the cookbook
     Then the prefer new notification syntax warning 043 should be displayed

  Scenario Outline: Applicability by Chef version
    Given a cookbook recipe with a resource that uses the old notification syntax
     When I check the cookbook specifying <version> as the Chef version
     Then the prefer new notification syntax warning 043 <displayed> be displayed
  Examples:
     | version | displayed  |
     | 0.7.6   | should not |
     | 0.8.16  | should not |
     | 0.9.0   | should not |
     | 0.9.10  | should     |
     | 0.9.18  | should     |
     | 0.10.0  | should     |
     | 10.24.0 | should     |
     | 11.4.0  | should     |
