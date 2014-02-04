Feature: Check for Chef Server

  In order to ensure my cookbooks can be run with chef solo
  As a developer
  I want to identify if server-only features are used without checking to see if this is server

  Scenario: Search without checking for server
    Given a cookbook with a single recipe that searches without checking if this is server
    When I check the cookbook
    Then the check for server warning 003 should be displayed

  Scenario: Search with older chef-solo-search
    Given a cookbook with a single recipe that searches without checking if this is server
      And another cookbook that has an older chef-solo-search installed
    When I check the cookbook
    Then the check for server warning 003 should not be displayed

  Scenario: Search with chef-solo-search
    Given a cookbook with a single recipe that searches without checking if this is server
      And another cookbook that has chef-solo-search installed
    When I check the cookbook
    Then the check for server warning 003 should not be displayed

  Scenario: Search checking for server
    Given a cookbook with a single recipe that searches but checks first to see if this is server
    When I check the cookbook
    Then the check for server warning 003 should not be displayed given we have checked

  Scenario: Search checking for server (unless)
    Given a cookbook with a single recipe that searches but checks with a negative first to see if this is server
    When I check the cookbook
    Then the check for server warning 003 should not be displayed given we have checked

  Scenario: Search checking for server (string access)
    Given a cookbook with a single recipe that searches but checks first (string) to see if this is server
    When I check the cookbook
    Then the check for server warning 003 should not be displayed given we have checked

  Scenario: Search checking for server (method access)
    Given a cookbook with a single recipe that searches but checks first (method) to see if this is server
    When I check the cookbook
    Then the check for server warning 003 should not be displayed given we have checked

  Scenario: Search checking for server (alternation)
    Given a cookbook with a single recipe that searches but checks first (alternation) to see if this is server
    When I check the cookbook
    Then the check for server warning 003 should not be displayed against the condition

  Scenario: Search checking for server (ternary)
    Given a cookbook with a single recipe that searches but checks first (ternary) to see if this is server
    When I check the cookbook
    Then the check for server warning 003 should not be displayed against the condition

  Scenario Outline: Search checking for server (return)
    Given a cookbook with a single recipe that searches but returns first (<format>) if search is not supported
    When I check the cookbook
    Then the check for server warning 003 should not be displayed against the search after the <format> conditional
  Examples:
    | format    |
    | oneline   |
    | multiline |
