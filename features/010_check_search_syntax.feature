Feature: Check for invalid search syntax

  In order to identify invalid search syntax that will cause my converge to fail
  As a developer
  I want to verify that search expressions use valid Lucene syntax

  Scenario: Invalid search syntax
    Given a cookbook recipe that attempts to perform a search with invalid syntax
    When I check the cookbook
    Then the invalid search syntax warning 010 should be displayed

  Scenario: Valid search syntax
    Given a cookbook recipe that attempts to perform a search with valid syntax
    When I check the cookbook
    Then the invalid search syntax warning 010 should not be displayed

  Scenario: Search with subexpression
    Given a cookbook recipe that attempts to perform a search with a subexpression
    When I check the cookbook
    Then the invalid search syntax warning 010 should not be displayed
