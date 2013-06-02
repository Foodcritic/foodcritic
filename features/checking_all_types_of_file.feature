Feature: Checking all types of files

In order to run foodcritic rules
As a developer
I want to be able to check all types of files

  Scenario: Checking recipe
    Given a cookbook with a recipe file with an interpolated name
    When I check the cookbook
    Then the string interpolation warning 002 should be displayed

  Scenario: Checking attribute
    Given a cookbook with an attribute file with an interpolated name
    When I check the cookbook
    Then the string interpolation warning 002 should be displayed against the attributes file

  Scenario: Checking metadata
    Given a cookbook with a metadata file with an interpolated name
    When I check the cookbook
    Then the string interpolation warning 002 should be displayed against the metadata file

  Scenario: Checking provider
    Given a cookbook with a provider file with an interpolated name
    When I check the cookbook
    Then the string interpolation warning 002 should be displayed against the provider file

  Scenario: Checking resource
    Given a cookbook with a resource file with an interpolated name
    When I check the cookbook
    Then the string interpolation warning 002 should be displayed against the resource file

  Scenario: Checking library
    Given a cookbook with a library file with an interpolated name
    When I check the cookbook
    Then the string interpolation warning 002 should be displayed against the libraries file

  Scenario: Checking definition
    Given a cookbook with a definition file with an interpolated name
    When I check the cookbook
    Then the string interpolation warning 002 should be displayed against the definition file
