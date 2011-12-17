Feature: Check for use of definitions

  In order to benefit from the additional features supported by first-class resources
  As a developer
  I want to identify when definitions are being used so they can be refactored to become LWRPs

  Scenario: Cookbook contains definition
    Given a cookbook that contains a definition
    When I check the cookbook
    Then the definitions are deprecated warning 015 should be displayed against the definition file

  Scenario: Cookbook does not contain a definition - no directory
    Given a cookbook that does not contain a definition and has no definitions directory
    When I check the cookbook
    Then the definitions are deprecated warning 015 should not be displayed against the definition file
     And no error should have occurred

  Scenario: Cookbook does not contain a definition - directory
    Given a cookbook that does not contain a definition and has a definitions directory
    When I check the cookbook
    Then the definitions are deprecated warning 015 should not be displayed against the definition file
