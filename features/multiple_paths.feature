Feature: Multiple paths

  In order to avoid needing to run foodcritic multiple times
  As a developer
  I want to lint multiple paths at once

  Scenario: Linting multiple individual cookbooks
    Given a cookbook with a single recipe that reads node attributes via symbols,strings
      And another cookbook with a single recipe that reads node attributes via strings
     When I check both cookbooks
     Then the attribute consistency warning 019 should be shown
