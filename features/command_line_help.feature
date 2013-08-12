Feature: Command line help

  In order to be able to learn about the options available for checking my cookbooks
  As a developer
  I want to be able to interactively get help on the options from the command line

  Scenario: No arguments
    Given I have installed the lint tool
     When I run it on the command line with no arguments
     Then the simple usage text should be displayed along with a non-zero exit code

  Scenario: Non-existent cookbook directory
    Given I have installed the lint tool
     When I run it on the command line specifying a cookbook that does not exist
     Then the simple usage text should be displayed along with a non-zero exit code

  Scenario: Non-existent role directory
    Given I have installed the lint tool
     When I run it on the command line specifying a role directory that does not exist
     Then the simple usage text should be displayed along with a non-zero exit code

  Scenario: Non-existent environment directory
    Given I have installed the lint tool
     When I run it on the command line specifying an environment directory that does not exist
     Then the simple usage text should be displayed along with a non-zero exit code

  Scenario: Command help
    Given I have installed the lint tool
     When I run it on the command line with the help option
     Then the simple usage text should be displayed along with a zero exit code

  Scenario: Display version
    Given I have installed the lint tool
     When I run it on the command line with the version option
     Then the current version should be displayed

  Scenario: Future verbose option
    Given I have installed the lint tool
     When I run it on the command line with the unimplemented verbose option
     Then the simple usage text should be displayed along with a non-zero exit code

  Scenario: Unimplemented option
    Given I have installed the lint tool
     When I run it on the command line with the unimplemented -Z option
     Then the simple usage text should be displayed along with a non-zero exit code

  Scenario: Future verbose option plus arguments
    Given a cookbook that has style problems
      And I have installed the lint tool
     When I run it on the command line with the unimplemented -v option with an argument
     Then the simple usage text should be displayed along with a non-zero exit code
     Then the style warning 002 should not be displayed
      And the current version should not be displayed

  Scenario: Refer to the man page
    Given access to the man page documentation
     When I compare the man page options against the usage options
     Then all options should be documented in the man page
