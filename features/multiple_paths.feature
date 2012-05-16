Feature: Multiple paths

  In order to avoid needing to run foodcritic multiple times
  As a developer
  I want to lint multiple paths at once

  Scenario: Linting multiple individual cookbooks
    Given a cookbook with a single recipe that reads node attributes via symbols only
      And another cookbook with a single recipe that reads node attributes via strings only
     When I check both cookbooks
     Then the node access warning 001 should be displayed
