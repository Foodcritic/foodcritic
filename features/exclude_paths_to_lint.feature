Feature: Exclude paths from being linted

  In order to avoid linting some paths that are not really from the cookbook
  As a developer
  I want to be able to exclude some files or directories from the passed paths

  Scenario: Exclude a non cookbook directory
    Given a cookbook that has style problems
      And unit tests under a top-level test directory
     When I check the cookbook excluding the test directory
     Then no warnings will be displayed against the tests
      And the style warning 002 should be displayed
