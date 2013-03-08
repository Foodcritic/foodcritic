Feature: Ignoring rules on per line basis

  To ignore specific warnings on some lines
  As a developer
  I want to add a ignore comment

  Scenario: Not ignoring
    Given a resource resource declared with the mode 644
    When I check the cookbook
    Then the file mode warning 006 should be invalid

  Scenario: Ignoring
    Given a resource resource declared with the mode 644 ignored from FC006
    When I check the cookbook
    Then the file mode warning 006 should be valid
