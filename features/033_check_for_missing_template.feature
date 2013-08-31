Feature: Check for missing template

  In order to ensure the Chef run is successful
  As a developer
  I want to identify template resources that refer to missing templates

  Scenario Outline: Template types
    Given a cookbook recipe that <template_type>
     When I check the cookbook
     Then the missing template warning 033 <warning>
  Examples:
    | template_type                                                             | warning                 |
    | defines a template where both the name and source are complex expressions | should not be displayed |
    | defines a template where name and source are both simple expressions      | should not be displayed |
    | defines a template where name is a complex expression                     | should not be displayed |
    | infers a template with an expression                                      | should not be displayed |
    | refers to a hidden template                                               | should not be displayed |
    | refers to a local template                                                | should not be displayed |
    | refers to a missing template                                              | should be displayed     |
    | refers to a template in a subdirectory                                    | should not be displayed |
    | refers to a template                                                      | should not be displayed |
    | refers to a template with an expression                                   | should not be displayed |
    | refers to a template without an erb extension                             | should not be displayed |
    | uses a missing inferred template                                          | should be displayed     |
    | uses an inferred template                                                 | should not be displayed |
    | uses a template from another cookbook                                     | should not be displayed |

  Scenario: Template within deploy resource
    Given a cookbook recipe with a deploy resource that contains a template resource
     When I check the cookbook
     Then the missing template warning 033 should not be displayed against the template
