Feature: Check for undeclared recipe dependencies

  In order to prevent failure of my Chef run due to a missing cookbook
  As a developer
  I want to identify included recipes that are not expressed in cookbook metadata

  Scenario: Cookbook includes undeclared recipe dependency
    Given a cookbook recipe that includes an undeclared recipe dependency
    When I check the cookbook
    Then the undeclared dependency warning 007 should be displayed

  Scenario: Cookbook includes undeclared recipe dependency unscoped
    Given a cookbook recipe that includes an undeclared recipe dependency unscoped
    When I check the cookbook
    Then the undeclared dependency warning 007 should be displayed

  Scenario: Cookbook includes recipe via expression
    Given a cookbook recipe that includes a recipe name from an expression
    When I check the cookbook
    Then the undeclared dependency warning 007 should not be displayed

  Scenario: Cookbook includes declared recipe dependency
    Given a cookbook recipe that includes a declared recipe dependency
    When I check the cookbook
    Then the undeclared dependency warning 007 should not be displayed

  Scenario: Cookbook includes declared recipe dependency unscoped
    Given a cookbook recipe that includes a declared recipe dependency unscoped
    When I check the cookbook
    Then the undeclared dependency warning 007 should not be displayed

  Scenario: Cookbook includes several declared recipe dependencies
    Given a cookbook recipe that includes several declared recipe dependencies - brace
    When I check the cookbook
    Then the undeclared dependency warning 007 should not be displayed

  Scenario: Cookbook includes several declared recipe dependencies
    Given a cookbook recipe that includes several declared recipe dependencies - block
    When I check the cookbook
    Then the undeclared dependency warning 007 should not be displayed

  Scenario: Cookbook includes mix of declared and undeclared recipe dependencies
    Given a cookbook recipe that includes both declared and undeclared recipe dependencies
    When I check the cookbook
    Then the undeclared dependency warning 007 should be displayed only for the undeclared dependencies

  Scenario: Cookbook includes local recipe
    Given a cookbook recipe that includes a local recipe
    When I check the cookbook
    Then the undeclared dependency warning 007 should not be displayed

  Scenario: Cookbook has no metadata file
    Given a cookbook that does not have defined metadata
    When I check the cookbook
    Then the undeclared dependency warning 007 should not be displayed
     And no error should have occurred
