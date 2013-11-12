Feature: Check for direct usage of git

  In order to access source control repositories idiomatically
  As a developer
  I want to use resources for repository access rather than executing git directly

  Scenario Outline: Execute resource
    Given a cookbook recipe with an execute resource named <name>
    When I check the cookbook
    Then the execute resource used to run git commands warning 040 <display> be displayed
  Examples:
    | name                   | display    |
    | git pull               | should     |
    | git clone              | should     |
    | git fetch              | should     |
    | git checkout           | should     |
    | git reset --hard       | should     |
    | git show               | should not |
    | echo 'bob' && git show | should not |
    | which foo              | should not |

  Scenario Outline: Execute resource
    Given a cookbook recipe with an execute resource that runs the command <command>
    When I check the cookbook
    Then the execute resource used to run git commands warning 040 <display> be displayed
  Examples:
    | command                                             | display    |
    | git clone https://github.com/git/git.git            | should     |
    | git clone --depth 10 https://github.com/git/git.git | should     |
    | git pull                                            | should     |
    | git fetch origin                                    | should     |
    | git checkout master                                 | should     |
    | git reset --hard                                    | should     |
    | git status && git pull                              | should     |
    | git show                                            | should not |
    | echo 'bob' && git show                              | should not |
    | gitk                                                | should not |
    | curl http://github.com/                             | should not |

  Scenario: Multiple execute resources
    Given a cookbook recipe with multiple execute resources where the last uses git
     When I check the cookbook
     Then the execute resource used to run git commands warning 040 should be displayed against the last resource
