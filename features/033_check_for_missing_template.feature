Feature: Check for missing template source file(s)

  In order to ensure the Chef run is successful
  As a developer
  I want to identify template resources that refer to missing templates

  Scenario Outline: Template types
    Given a cookbook recipe that <template_type>
     When I check the cookbook
     Then the warning 033 should be <warning>
  Examples:
    | template_type                                                             | warning |
    | defines a template where both the name and source are complex expressions | valid   |
    | defines a template where name and source are both simple expressions      | valid   |
    | defines a template where name is a complex expression                     | valid   |
    | infers a template with an expression                                      | valid   |
    | refers to a hidden template                                               | valid   |
    | refers to a local template                                                | valid   |
    | refers to a missing template                                              | invalid |
    | refers to a template in a subdirectory                                    | valid   |
    | refers to a template                                                      | valid   |
    | refers to a template with an expression                                   | valid   |
    | refers to a template without an erb extension                             | valid   |
    | uses a missing inferred template                                          | invalid |
    | uses an inferred template                                                 | valid   |
    | uses a template from another cookbook                                     | valid   |
    | includes a deploy resource that contains a template resource              | valid   |
    | includes a template in the root of the templates directory                | valid   |
