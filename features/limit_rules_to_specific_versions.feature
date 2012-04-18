Feature: Limit rules to specific versions

  In order to not be shown warnings that do not apply to my version of Chef
  As a developer
  I want to be able to specify the version of Chef I am using

  Scenario: Rule with no version constraint - no version specified
    Given a rule that does not declare a version constraint
      And a cookbook that matches that rule
     When I check the cookbook without specifying a Chef version
     Then the warning should be displayed

  Scenario Outline: Rule with no version constraint - specifying version
    Given a rule that does not declare a version constraint
      And a cookbook that matches that rule
     When I check the cookbook specifying <version> as the Chef version
     Then the warning should be displayed

    Examples:
      | version        |
      | 0.10.10.beta.1 |
      | 0.10.8         |
      | 0.10.6         |
      | 0.10.6.rc.5    |
      | 0.10.6.beta.3  |
      | 0.10.4         |
      | 0.10.2         |
      | 0.10.0         |
      | 0.9.18         |

  Scenario: Rule with version constraint - no version specified
    Given a rule that declares a version constraint
      And the current stable version of Chef falls within it
      And a cookbook that matches that rule
     When I check the cookbook without specifying a Chef version
     Then the warning should be displayed

  Scenario: Rule with version constraint - no version specified
    Given a rule that declares a version constraint
      And the current stable version of Chef does not fall within it
      And a cookbook that matches that rule
     When I check the cookbook without specifying a Chef version
     Then the warning should not be displayed

  Scenario Outline: Rule with version constraint - specifying version
    Given a rule that declares a version constraint of <from_version> to <to_version>
      And a cookbook that matches that rule
     When I check the cookbook specifying <version> as the Chef version
     Then the warning <warning>

    Examples:
      | version        | from_version | to_version | warning                 |
      | 0.10.10.beta.1 | 0.10.10      |            | should not be displayed |
      | 0.10.10        | 0.10.10      |            | should be displayed     |
      | 0.10.8         | 0.10.10      |            | should not be displayed |
      | 0.10.6.rc.5    | 0.10.8       |            | should not be displayed |
      | 0.10.6.rc.5    | 0.10.6       |            | should not be displayed |
      | 0.10.4         | 0.9.14       |            | should be displayed     |
      | 0.10.4         | 0.10.10      |            | should not be displayed |
      | 0.10.8         | 0.9.18       | 0.10.6     | should not be displayed |
      | 0.10.6         | 0.9.18       | 0.10.6     | should be displayed     |
      | 0.9.18         | 0.9.18       | 0.10.6     | should be displayed     |
      | 0.9.14         | 0.9.18       | 0.10.6     | should not be displayed |
      | 0.9.14         |              | 0.10.6     | should be displayed     |
      | 0.9.14         |              | 0.9.12     | should not be displayed |
