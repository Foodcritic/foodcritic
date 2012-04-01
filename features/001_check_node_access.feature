Feature: Check Node Access

  In order to be consistent in the way I access node attributes and to avoid confusing people new to Ruby
  As a developer
  I want to identify if the cookbooks access node attributes with symbols rather than strings

  Scenario: Cookbook recipe accesses attributes via symbols
    Given a cookbook with a single recipe that reads node attributes via symbols
    When I check the cookbook
    Then the node access warning 001 should be displayed

  Scenario: Cookbook recipe accesses multiple attributes via symbols
    Given a cookbook with a single recipe that accesses multiple node attributes via symbols
    When I check the cookbook
    Then the node access warning 001 should be displayed for each match

  Scenario: Assignment of node attributes accessed via symbols
    Given a cookbook with a single recipe that assigns node attributes accessed via symbols to a local variable
    When I check the cookbook
    Then the node access warning 001 should be displayed

  Scenario: Cookbook recipe accesses nested attributes via symbols
    Given a cookbook with a single recipe that accesses nested node attributes via symbols
    When I check the cookbook
    Then the node access warning 001 should be displayed twice for the same line

  Scenario: Cookbook recipe accesses attributes via strings
    Given a cookbook with a single recipe that reads node attributes via strings
    When I check the cookbook
    Then the node access warning 001 should not be displayed

  Scenario: Cookbook recipe access attributes via strings and searches
    Given a cookbook with a single recipe that searches based on a node attribute accessed via strings
    When I check the cookbook
    Then the node access warning 001 should not be displayed

  Scenario: Cookbook recipe access attributes via symbols for template
    Given a cookbook with a single recipe that passes node attributes accessed via symbols to a template
    When I check the cookbook
    Then the node access warning 001 should be displayed against the variables

  Scenario: Cookbook recipe sets default attributes via symbols
    Given a cookbook that declares default attributes via symbols
    When I check the cookbook
    Then the node access warning 001 should be displayed against the attributes file

  Scenario: Cookbook recipe overrides attributes via symbols
    Given a cookbook that declares override attributes via symbols
    When I check the cookbook
    Then the node access warning 001 should be displayed against the attributes file

  Scenario: Cookbook recipe sets attributes via symbols
    Given a cookbook that declares set attributes via symbols
    When I check the cookbook
    Then the node access warning 001 should be displayed against the attributes file

  Scenario: Cookbook recipe sets normal attributes via symbols
    Given a cookbook that declares normal attributes via symbols
    When I check the cookbook
    Then the node access warning 001 should be displayed against the attributes file
