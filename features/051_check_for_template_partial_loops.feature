Feature: Check for template partial includes cycle

  In order to avoid failures at converge time
  As a developer
  I want to identify when a template uses partials that would loop

  Scenario: Template without includes
    Given a cookbook recipe that refers to a template
    When I check the cookbook
    Then the template partials loop indefinitely warning 051 should not be displayed against the templates

  Scenario: Template includes do not cycle
    Given a template that includes a partial
     When I check the cookbook
     Then the template partials loop indefinitely warning 051 should not be displayed against the templates

  Scenario: Template includes contain cycle
    Given a template that includes a partial that includes the original template again
     When I check the cookbook
     Then the template partials loop indefinitely warning 051 should be displayed against the templates
      And no error should have occurred

  Scenario: Relative partial
    Given a template that includes a partial with a relative subdirectory path
     When I check the cookbook
     Then the template partials loop indefinitely warning 051 should not be displayed against the templates
      And no error should have occurred

  Scenario: Missing partial
    Given a template that includes a missing partial with a relative subdirectory path
     When I check the cookbook
     Then the template partials loop indefinitely warning 051 should not be displayed against the templates
      And no error should have occurred

  Scenario Outline: Template directory contains binary files
    Given a template directory that contains a binary file <file> that is not valid UTF-8
     When I check the cookbook
     Then the template partials loop indefinitely warning 051 should not be displayed against the templates
      And no error should have occurred
  Examples:
    | file        |
    | .DS_Store   |
    | foo.erb.swp |
