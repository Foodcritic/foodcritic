Feature: Check for direct usage of curl or wget

  In order to fetch remote artefacts idiomatically
  As a developer
  I want to use resources to download rather than using curl or wget

  Scenario Outline: Execute resource
    Given a cookbook recipe with an execute resource named <name>
    When I check the cookbook
    Then the execute resource used to run curl or wget commands warning 041 <display> be displayed
  Examples:
    | name                       | display    |
    | curl 'http://example.org/' | should not |
    | wget 'http://example.org/' | should     |
    | which curl                 | should not |
    | sudo wget                  | should not |
    | reboot                     | should not |

  Scenario Outline: Execute resource
    Given a cookbook recipe with an execute resource that runs the command <command>
    When I check the cookbook
    Then the execute resource used to run curl or wget commands warning 041 <display> be displayed
  Examples:
    | command                                    | display     |
    | which curl                                 | should not  |
    | sudo wget                                  | should not  |
    | curl -X POST 'http://example.org/'         | should not  |
    | curl 'http://example.org/'                 | should not  |
    | curl 'http://example.org/' -o foo          | should      |
    | curl 'http://example.org/'  --output   foo | should      |
    | curl 'http://example.org/' &>bar           | should      |
    | curl -o baz 'http://example.org/'>   bing  | should      |
    | wget 'http://example.org/'                 | should      |
    | mkdir foo && wget 'http://example.org/'    | should      |
