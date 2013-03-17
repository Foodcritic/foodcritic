Feature: Ignoring rules on per line basis

  To ignore specific warnings on some lines
  As a developer
  I want to add a ignore comment

  Scenario: Not ignoring
    Given a resource resource declared with the mode 644
    When I check the cookbook
    Then the file mode warning 006 should be invalid

  Scenario: Ignoring
    Given a resource resource declared with the mode 644 ignored from 'FC006'
    When I check the cookbook
    Then the file mode warning 006 should be valid

  Scenario: Ignoring multiple
    Given a resource resource declared with the mode 644 ignored from 'FC003, FC006, FC009'
    When I check the cookbook
    Then the file mode warning 006 should be valid

  Scenario: Ignoring multiple but not ignoring the current
    Given a resource resource declared with the mode 644 ignored from 'FC003, FC009'
    When I check the cookbook
    Then the file mode warning 006 should be invalid

  Scenario: File with multiple errors on 1 line
    Given a file with multiple errors on 1 line
    When I check the cookbook
    Then the file mode warning 002 should be invalid
    Then the file mode warning 039 should be invalid

  Scenario: Ignoring multiple the errors on 1 line
    Given a file with multiple errors on 1 line ignored from 'FC002, FC039'
    When I check the cookbook
    Then the file mode warning 002 should be valid
    Then the file mode warning 039 should be valid

  Scenario: Ignoring 1 of multiple errors on 1 line
    Given a file with multiple errors on 1 line ignored from 'FC002'
    When I check the cookbook
    Then the file mode warning 002 should be valid
    Then the file mode warning 039 should be invalid
