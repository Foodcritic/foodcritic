Feature: Sort warnings

  In order to make it easier to see which lines of my recipe have been flagged with warnings
  As a developer
  I want warnings to appear in line order

  Scenario: Recipe has warnings on lines that don't sort non-numerically
    Given a cookbook with a single recipe which accesses node attributes with symbols on lines 2 and 10
    When I check the cookbook
    Then the node access warning 001 should warn on lines 2 and 10 in that order