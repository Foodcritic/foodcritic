Feature: Ignoring rules on per line basis

  To ignore specific warnings on some lines
  As a developer
  I want to add an ignore comment

  Scenario Outline: Ignoring
    Given a file resource declared with the mode 644 with comment <comment>
    When I check the cookbook
    Then the warning 006 should <shown>
  Examples:
    | comment                      | shown        |
    |                              | be shown     |
    | #                            | be shown     |
    | # foo bar baz                | be shown     |
    | # ~FC006                     | not be shown |
    | # ~FC006 is a false positive | not be shown |
    | #~FC006                      | not be shown |
    | #~FC022                      | be shown     |
    | #       ~FC006               | not be shown |
    | # ~FC003,~FC006,~FC009       | not be shown |
    | # ~FC003 ~FC006 ~FC009       | not be shown |
    | # ~FC003,  ~FC006,  ~FC009   | not be shown |
    | # ~FC003,~FC009              | be shown     |
    | # FC006                      | be shown     |
    | # ~ FC006                    | be shown     |
    | # fc006                      | be shown     |
    | # ~006                       | be shown     |
    | # ~style                     | be shown     |
    | # ~files                     | not be shown |

  Scenario Outline: Ignoring cookbook level rules
    Given a cookbook with a single recipe that triggers FC019 with comment <comment>
      And metadata
    When I check the cookbook
    Then the attribute consistency warning 019 should <shown>
    Examples:
      | comment | shown        |
      |         | be shown     |
      | #~FC019 | be not shown |

  Scenario Outline: Multiple warnings
    Given a file with multiple errors on one line with comment <comment>
    When I check the cookbook
    Then the warnings shown should be <warnings>
  Examples:
    | comment         | warnings    |
    |                 | FC002,FC039 |
    | # ~FC002,~FC007 | FC002       |
    | # ~FC002,~FC039 |             |
    | # ~FC002        | FC039       |

  Scenario Outline: Ignoring role rules
    Given a ruby role that triggers FC049 with comment <comment>
     When I check the role directory
     Then the role name does not match file name warning 049 should <shown>
  Examples:
    | comment | shown        |
    |         | be shown     |
    | #~FC049 | not be shown |

  Scenario Outline: Ignoring environment rules
    Given a ruby environment that triggers FC050 with comment <comment>
     When I check the environment directory
     Then the invalid environment name warning 050 should <shown>
  Examples:
    | comment | shown        |
    |         | be shown     |
    | #~FC050 | not be shown |
