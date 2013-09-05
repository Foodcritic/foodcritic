Feature: External reporting

  In order to be able to quickly identify problems with my cookbooks
  As a developer
  I want to have output in a reporting format that my tools understand

  Scenario: Command help
    Given I have installed the lint tool
     When I run it on the command line with the help option
     Then the usage text should include an option for specifying the reporter
     Then the usage text should include an option for specifying external reporters
     Then the usage text should include an option for specifying report destination

  Scenario: Reporting using the chosen reporter
    Given I have installed the lint tool
     When I run it on the command line with the external reporter output option
     Then the external reporter is used


