Feature: Check for consistency in node access

  In order to be consistent in the way I access node attributes
  As a developer
  I want to identify if the same cookbook uses varying approaches to accessing node attributes

  Scenario: Cookbook recipe accesses attributes via symbols
    Given a cookbook with a single recipe that accesses node attributes via symbols only
    When I check the cookbook
    Then the attribute consistency warning 019 should not be displayed

  Scenario: Cookbook recipe accesses attributes via strings only
    Given a cookbook with a single recipe that accesses node attributes via strings only
    When I check the cookbook
    Then the attribute consistency warning 019 should not be displayed

  Scenario: Cookbook recipe accesses attributes in multiple ways
    Given a cookbook with a single recipe that accesses node attributes via strings and symbols
    When I check the cookbook
    Then the attribute consistency warning 019 should be displayed

  Scenario: Cookbook recipe does not access attributes
    Given a cookbook with a single recipe that does not access node attributes
    When I check the cookbook
    Then the attribute consistency warning 019 should not be displayed

  Scenario: Cookbook accesses attributes in multiple ways
    Given a cookbook that declares default attributes via symbols
      And a recipe that reads them as strings
    When I check the cookbook
    Then the attribute consistency warning 019 should be displayed

  Scenario: Two cookbooks with differing approaches
    Given a cookbook with a single recipe that accesses node attributes via strings only
      And another cookbook with a single recipe that accesses node attributes via symbols only
     When I check the cookbook tree
    Then the attribute consistency warning 019 should not be displayed
