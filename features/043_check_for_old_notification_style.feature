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
