Feature: Identify roles names that do not match filenames

  In order to avoid confusion
  As a developer
  I want to identify roles whose names differ from their filename

  Scenario Outline: Illustrates role paths
    Given a directory that contains a role file <filename> in <format> that defines role name <role_name>
     When I check the role directory as a <path_type> path
     Then the role name does not match file name warning 049 <show_warning> be shown
  Examples:
    | filename       | format | role_name | path_type | show_warning |
    | webserver.rb   | ruby   | webserver | role      | should not   |
    | webserver.rb   | ruby   | apache    | role      | should       |
    | webserver.json | json   | webserver | role      | should not   |
    | webserver.json | json   | apache    | role      | should not   |
    | webserver.rb   | ruby   | webserver | cookbook  | should not   |
    | webserver.rb   | ruby   | apache    | cookbook  | should not   |
    | webserver.rb   | ruby   | webserver | default   | should not   |
    | webserver.rb   | ruby   | apache    | default   | should not   |

  Scenario: Role name references variable
    Given a directory that contains a ruby role with an expression as its name
     When I check the role directory
     Then the role name does not match file name warning 049 should not be shown

  Scenario: Multiple role names declared
    Given a directory that contains a ruby role that declares the role name more than once
      And the last role name declared does not match the containing filename
     When I check the role directory
     Then the role name does not match file name warning 049 should be shown against the second name
