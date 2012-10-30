@context
Feature: Show Lines Matched

  In order to understand more quickly the reason for a warning
  As a developer
  I want to be able to see the lines the warning matches against, with context

  Scenario: Recipe with a single warning
    Given a cookbook with a single recipe that reads node attributes via symbols,strings
     When I check the cookbook, specifying that context should be shown
     Then the recipe filename should be displayed
      And the attribute consistency warning 019 should be displayed below
      And the line number and line of code that triggered the warning should be displayed

  Scenario: Recipe with a multiple warnings of the same type
    Given a cookbook with a single recipe that reads multiple node attributes via symbols,strings
     When I check the cookbook, specifying that context should be shown
     Then the recipe filename should be displayed
      And the attribute consistency warning 019 should be displayed below
      And the line number and line of code that triggered the warnings should be displayed
