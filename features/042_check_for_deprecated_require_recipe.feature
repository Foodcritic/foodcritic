Feature: Check for deprecated require recipe

  In order to prevent failure of my cookbooks in future versions of Chef
  As a developer
  I want to use include_recipe in preference to require_recipe

  Scenario: Recipe uses require_recipe
    Given a recipe that uses require_recipe
    When I check the cookbook
    Then the require_recipe deprecated warning 042 should be displayed

  Scenario: Recipe does not use require_recipe
    Given a recipe that uses include_recipe
    When I check the cookbook
    Then the require_recipe deprecated warning 042 should not be displayed
