Feature: Check for hard-coded temp directory

  In order to ensure that my cookbook works on a server that may have limited /tmp space
  As a developer
  I want to identify if my cookbook is hard-coding references to /tmp rather than using the Chef file cache path

  Scenario: Download to hard-coded temp directory
    Given a cookbook that downloads a file to /tmp
    When I check the cookbook
    Then the hard-coded temp directory warning 013 should be displayed

  Scenario: Download to hard-coded temp directory (expression)
    Given a cookbook that downloads a file to /tmp with an expression
    When I check the cookbook
    Then the hard-coded temp directory warning 013 should be displayed

  Scenario: Download to Chef file cache
    Given a cookbook that downloads a file to the Chef file cache
    When I check the cookbook
    Then the hard-coded temp directory warning 013 should not be displayed

  Scenario: Download to anywhere else
    Given a cookbook that downloads a file to a users home directory
    When I check the cookbook
    Then the hard-coded temp directory warning 013 should not be displayed
