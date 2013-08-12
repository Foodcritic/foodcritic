Feature: Check for invalid names

  In order to identify issues more quickly
  As a developer
  I want to identify roles or environments whose names are invalid

  Scenario Outline: Role name validity
    Given a ruby role file that defines a role with name <role_name>
     When I check the role directory
     Then the invalid role name warning 050 <show_warning> be shown
  Examples:
    | role_name    | show_warning |
    | webserver    | should not   |
    | web_server   | should not   |
    | web-server   | should not   |
    | webserver123 | should not   |
    | Webserver    | should not   |
    | web server   | should       |
    | webserver%   | should       |

  Scenario Outline: Environment name validity
    Given a ruby environment file that defines an environment with name <environment_name>
     When I check the environment directory
     Then the invalid environment name warning 050 <show_warning> be shown
  Examples:
    | environment_name     | show_warning |
    | production           | should not   |
    | pre_production       | should not   |
    | production-eu        | should not   |
    | production2          | should not   |
    | Production           | should not   |
    | EU West              | should       |
    | production (eu-west) | should       |
