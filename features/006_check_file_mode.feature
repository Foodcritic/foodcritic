Feature: Check file mode

  In order to ensure that file and directory permissions are applied correctly
  As a developer
  I want to identify where the mode may not be interpreted as expected

  Scenario Outline: Specifying file mode
    Given a <resource> resource declared with the mode <mode>
    When I check the cookbook
    Then the warning 006 should be <shown_where_invalid>

    Examples:
      | resource      | mode   | shown_where_invalid |
      | cookbook_file |  "644" |   valid             |
      | cookbook_file |   644  | invalid             |
      | cookbook_file | 00644  |   valid             |
      | directory     |   755  | invalid             |
      | directory     |  "755" |   valid             |
      | directory     |  0644  |   valid             |
      | directory     | "0644" |   valid             |
      | directory     |   400  | invalid             |
      | directory     | 00400  |   valid             |
      | file          |  "755" |   valid             |
      | file          |   755  | invalid             |
      | file          |   644  | invalid             |
      | file          |   044  | invalid             |
      | file          | "0644" |   valid             |
      | file          | ary[1] |   valid             |
      | template      |  00400 |   valid             |
      | template      |   400  | invalid             |
      | template      |  "400" |   valid             |

  Scenario: Unspecified mode
    Given a file resource declared without a mode
    When I check the cookbook
    Then the warning 006 should not be displayed
