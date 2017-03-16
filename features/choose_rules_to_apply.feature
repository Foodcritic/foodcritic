Feature: Choose rules to apply

  In order to remove warnings that are not appropriate for my usage of Chef
  As a developer
  I want to be able to filter the rules applied based on tags associated with each rule

  Scenario Outline: Specified tags on command line
    Given a cookbook that matches rules <cookbook_matches>
    When I check the cookbook specifying tags <tag_arguments>
    Then the warnings shown should be <warnings_shown>

  Examples:
    | cookbook_matches  | tag_arguments                      | warnings_shown    |
    | FC002,FC004,FC005 |                                    | FC002,FC004,FC005 |
    | FC002             | -t FC002                           | FC002             |
    | FC002,FC004,FC005 | --tags FC002                       | FC002             |
    | FC002,FC004,FC005 | --tags fc002                       |                   |
    | FC002,FC004,FC005 | --tags FC006                       |                   |
    | FC002,FC004,FC005 | --tags ~FC002                      | FC004,FC005       |
    |                   | --tags FC002                       |                   |
    | FC002,FC004,FC005 | --tags @FC002                      |                   |
    | FC002,FC004,FC005 | --tags style                       | FC002             |
    | FC002,FC004,FC005 | --tags FC002 --tags FC004          |                   |
    | FC002,FC004,FC005 | --tags portability --tags services | FC004             |
    | FC002,FC004,FC005 | --tags style,services,portability  | FC002,FC004       |

  Scenario Outline: Specified tags in cookbook .foodcritic file
    Given a cookbook that matches rules <cookbook_matches>
    When the cookbook directory has a .foodcritic file specifying tags <tag_file>
    And I check the cookbook specifying tags <tag_arguments>
    Then the warnings shown should be <warnings_shown>

  Examples:
    | cookbook_matches  | tag_file          | tag_arguments  | warnings_shown    |
    | FC002,FC004       |                   |                | FC002,FC004       |
    | FC002             | FC002             |                | FC002             |
    | FC002             | ~FC002            | --tags FC002   | FC002             |
    | FC002             | fc002             |                |                   |
    | FC002,FC004       | FC005             |                |                   |
    | FC002,FC004       | FC005             | -t FC002       | FC002             |
    | FC002,FC004       | ~FC002            |                | FC004             |
    | FC002,FC004       | ~FC002            | -t FC002       | FC002             |
    |                   | FC002             |                |                   |
    | FC002,FC004       | @FC002            |                |                   |
    | FC002,FC004       | style             |                | FC002             |
    | FC002,FC004       | FC002             |                |                   |
    | FC002,FC004       | style,portability |                | FC002,FC004       |
