Feature: Check for library providers that declare use_inline_resources and declare action_<name> methods

  In order to ensure that notifications happen correctly
  As a cookbook provider author
  I want to always use_inline_resources

  Scenario: Library provider with use_inline_resources and bad action_create
    Given a cookbook that contains a library provider with use_inline_resources and uses def action_create
     When I check the cookbook
     Then the library provider without use_inline_resources and bad action_create warning 058 should be displayed against the libraries file on line 11

  Scenario: Library provider without use_inline_resources and (okay) action_create
    Given a cookbook that contains a library provider without use_inline_resources and uses def action_create
     When I check the cookbook
     Then the library provider without use_inline_resources and bad action_create warning 058 should not be displayed against the libraries file

  Scenario: Library provider without use_inline_resources
    Given a cookbook that contains a library provider without use_inline_resources
     When I check the cookbook
     Then the library provider without use_inline_resources and bad action_create warning 058 should not be displayed against the libraries file

  Scenario: Library provider with use_inline_resources
    Given a cookbook that contains a library provider with use_inline_resources
     When I check the cookbook
     Then the library provider without use_inline_resources and bad action_create warning 058 should not be displayed against the libraries file
