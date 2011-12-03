Feature: Check String Interpolation

  In order to make my cookbooks more readable
  As a developer
  I want to identify if values are unnecessarily interpolated

  Scenario: Resource name interpolated string (symbol)
    Given a cookbook with a single recipe that creates a directory resource with an interpolated name
    When I check the cookbook
    Then the string interpolation warning 002 should be displayed

  Scenario: Resource name interpolated string
    Given a cookbook with a single recipe that creates a directory resource with an interpolated name from a string
    When I check the cookbook
    Then the string interpolation warning 002 should be displayed

  Scenario: Resource name string literal
    Given a cookbook with a single recipe that creates a directory resource with a string literal
    When I check the cookbook
    Then the string interpolation warning 002 should not be displayed

  Scenario: Resource name compound expression
    Given a cookbook with a single recipe that creates a directory resource with a compound expression
    When I check the cookbook
    Then the string interpolation warning 002 should not be displayed

  Scenario: Resource name literal and interpolated
    Given a cookbook with a single recipe that creates a directory resource with a literal and interpolated variable
    When I check the cookbook
    Then the string interpolation warning 002 should not be displayed

  Scenario: Resource name interpolated and literal
    Given a cookbook with a single recipe that creates a directory resource with an interpolated variable and a literal
    When I check the cookbook
    Then the string interpolation warning 002 should not be displayed