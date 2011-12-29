Feature: Check for Chef Server

  In order to ensure my cookbooks can be run with chef solo
  As a developer
  I want to identify if server-only features are used without checking to see if this is server

  Scenario: Search without checking for server
    Given a cookbook with a single recipe that searches without checking if this is server
    When I check the cookbook
    Then the check for server warning 003 should be displayed

  Scenario: Search with chef-solo-search
    Given a cookbook with a single recipe that searches without checking if this is server
      And another cookbook that has chef-solo-search installed
    When I check the cookbook
    Then the check for server warning 003 should not be displayed

  Scenario: Search checking for server
    Given a cookbook with a single recipe that searches but checks first to see if this is server
    When I check the cookbook
    Then the check for server warning 003 should not be displayed given we have checked