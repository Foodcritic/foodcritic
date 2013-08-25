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
