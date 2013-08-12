Feature: Multiple paths

  In order to avoid needing to run foodcritic multiple times
  As a developer
  I want to lint multiple paths at once

  Scenario Outline: Linting multiple individual cookbooks
    Given a cookbook with a single recipe that reads node attributes via symbols,strings
      And another cookbook with a single recipe that reads node attributes via strings
     When I check both cookbooks with the command-line <command_line>
     Then the attribute consistency warning 019 should be shown
  Examples:
    | command_line                                            |
    | example another_example                                 |
    | -B example -B another_example                           |
    | --cookbook-path example --cookbook-path another_example |
    | -B example another_example                              |
    | --cookbook-path example another_example                 |
    | -B example --cookbook-path another_example              |

  Scenario: Linting multiple role directories
    Given two roles directories
      And each role directory has a role with a name that does not match the containing file name
     When I check both roles directories
     Then the role name does not match file name warning 049 should be shown against the files in both directories

  Scenario: Linting a cookbook, role and environment together
    Given a cookbook with a single recipe that reads node attributes via symbols,strings
      And another cookbook with a single recipe that reads node attributes via strings
      And a directory that contains a role file webserver.rb in ruby that defines role name apache
      And a directory that contains an environment file production.rb in ruby that defines environment name production (us-east)
     When I check the cookbooks, role and environment together
     Then the attribute consistency warning 019 should be shown
      And the role name does not match file name warning 049 should be shown
      And the invalid environment name warning 050 should be shown
