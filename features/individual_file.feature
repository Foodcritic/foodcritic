Feature: Individual file

  In order to get even faster feedback on changes to cookbooks
  As a developer
  I want to lint individual files in a cookbook

  Scenario: Linting an individual file shows warnings only from that file
    Given a cookbook with a single recipe that reads node attributes via symbols
      And a cookbook that declares normal attributes via symbols
     When I check the recipe
     Then the node access warning 001 should be displayed for the recipe
      And the node access warning 001 should not be displayed for the attributes
