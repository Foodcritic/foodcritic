Feature: Check for missing template

  In order to ensure the Chef run is successful
  As a developer
  I want to identify template resources that refer to missing templates

  Scenario: Missing template
    Given a cookbook recipe that refers to a missing template
     When I check the cookbook
     Then the missing template warning 033 should be displayed

  Scenario: Present template
    Given a cookbook recipe that refers to a template
     When I check the cookbook
     Then the missing template warning 033 should not be displayed

  Scenario: Local template
    Given a cookbook recipe that refers to a local template
     When I check the cookbook
     Then the missing template warning 033 should not be displayed
