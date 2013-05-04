Feature: Check for missing template

  In order to ensure the Chef run is successful
  As a developer
  I want to identify template resources that refer to missing templates

  Scenario: Missing template
    Given a cookbook recipe that refers to a missing template
     When I check the cookbook
     Then the missing template warning 033 should be displayed

  Scenario: Missing template (inferred)
    Given a cookbook recipe that uses a missing inferred template
     When I check the cookbook
     Then the missing template warning 033 should be displayed

  Scenario: Present template
    Given a cookbook recipe that refers to a template
     When I check the cookbook
     Then the missing template warning 033 should not be displayed

  Scenario: Present template (not .erb)
    Given a cookbook recipe that refers to a template without an erb extension
     When I check the cookbook
     Then the missing template warning 033 should not be displayed

  Scenario: Present template (subdirectory)
    Given a cookbook recipe that refers to a template in a subdirectory
     When I check the cookbook
     Then the missing template warning 033 should not be displayed

  Scenario: Present template (inferred)
    Given a cookbook recipe that uses an inferred template
     When I check the cookbook
     Then the missing template warning 033 should not be displayed

  Scenario: Template present in another cookbook
    Given a cookbook recipe that uses a template from another cookbook
     When I check the cookbook
     Then the missing template warning 033 should not be displayed

  Scenario: Local template
    Given a cookbook recipe that refers to a local template
     When I check the cookbook
     Then the missing template warning 033 should not be displayed

  Scenario: Template source name is an expression
    Given a cookbook recipe that refers to a template with an expression
     When I check the cookbook
     Then the missing template warning 033 should not be displayed

  Scenario: Template source is an expression (inferred)
    Given a cookbook recipe that infers a template with an expression
     When I check the cookbook
     Then the missing template warning 033 should not be displayed

  Scenario: Template name and source are expressions
    Given a cookbook recipe that defines a template where name and source are both simple expressions
     When I check the cookbook
     Then the missing template warning 033 should not be displayed

  Scenario: Template name is a complex expression
    Given a cookbook recipe that defines a template where name is a complex expression
     When I check the cookbook
     Then the missing template warning 033 should not be displayed

  Scenario: Template name and source are complex expressions
    Given a cookbook recipe that defines a template where both the name and source are complex expressions
     When I check the cookbook
     Then the missing template warning 033 should not be displayed

  Scenario: Template within deploy resource
    Given a cookbook recipe with a deploy resource that contains a template resource
     When I check the cookbook
     Then the missing template warning 033 should not be displayed against the template
