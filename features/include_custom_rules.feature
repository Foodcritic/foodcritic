Feature: Include custom rules

  In order to be able detect cookbook issues that are specific to my organisation
  As a developer
  I want to be able to write custom rules and include them in my check

  Scenario: Valid custom rule
    Given a cookbook with a single recipe that reads node attributes via strings
      And I have installed the lint tool
     When I run it on the command line including a custom rule file containing a rule that matches
     Then a warning for the custom rule should be displayed

  Scenario: Valid custom rules (directory)
    Given a cookbook with a single recipe that reads node attributes via strings
      And I have installed the lint tool
     When I run it on the command line including a custom rule directory containing a rule that matches
     Then a warning for the custom rule should be displayed

  Scenario: Missing file
    Given a cookbook with a single recipe that reads node attributes via strings
      And I have installed the lint tool
     When I run it on the command line including a missing custom rule file
     Then a 'No such file or directory' error should be displayed

  Scenario: Non-ruby file
    Given a cookbook with a single recipe that reads node attributes via strings
      And I have installed the lint tool
     When I run it on the command line including a file which does not contain Ruby code
     Then an 'undefined method' error should be displayed
