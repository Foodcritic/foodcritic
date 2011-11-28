Feature: Check Node Access

  In order to make my cookbooks more readable
  As a developer
  I want to identify if the cookbooks access node attributes with strings rather than symbols

  Scenario: Cookbook recipe accesses attributes via strings
    Given a cookbook with a single recipe that accesses node attributes via strings
    When I check the cookbook
    Then the node access warning 001 should be displayed

  Scenario: Cookbook recipe accesses multiple attributes via strings
    Given a cookbook with a single recipe that accesses multiple node attributes via strings
    When I check the cookbook
    Then the node access warning 001 should be displayed for each match

  Scenario: Assignment of node attributes accessed via strings
    Given a cookbook with a single recipe that assigns node attributes accessed via strings to a local variable
    When I check the cookbook
    Then the node access warning 001 should be displayed

  Scenario: Cookbook recipe accesses nested attributes via strings
    Given a cookbook with a single recipe that accesses nested node attributes via strings
    When I check the cookbook
    Then the node access warning 001 should be displayed twice for the same line

  Scenario: Cookbook recipe accesses attributes via symbols
    Given a cookbook with a single recipe that accesses node attributes via symbols
    When I check the cookbook
    Then the node access warning 001 should not be displayed

  Scenario: Cookbook recipe sets default attributes via strings
    Given a cookbook that declares default attributes via strings
    When I check the cookbook
    Then the node access warning 001 should be displayed against the attributes file

  Scenario: Cookbook recipe overrides attributes via strings
    Given a cookbook that declares override attributes via strings
    When I check the cookbook
    Then the node access warning 001 should be displayed against the attributes file

  Scenario: Cookbook recipe sets attributes via strings
    Given a cookbook that declares set attributes via strings
    When I check the cookbook
    Then the node access warning 001 should be displayed against the attributes file

  Scenario: Cookbook recipe sets normal attributes via strings
    Given a cookbook that declares normal attributes via strings
    When I check the cookbook
    Then the node access warning 001 should be displayed against the attributes file
