Feature: Check for library providers that do not declare use_inline_resources

  In order to ensure that notifications happen correctly
  As a cookbook provider author
  I want to always use_inline_resources

  Scenario: Library provider with use_inline_resources
    Given a cookbook that contains a library provider with use_inline_resources
     When I check the cookbook
     Then the library provider without use_inline_resources warning 057 should not be displayed against the libraries file

  Scenario: Library provider without use_inline_resources
    Given a cookbook that contains a library provider without use_inline_resources
     When I check the cookbook
     Then the library provider without use_inline_resources warning 057 should be displayed against the libraries file on line 11

  Scenario: Library file without use_inline_resources
    Given a cookbook that contains a library resource
     When I check the cookbook
     Then the library provider without use_inline_resources warning 057 should not be displayed against the libraries file
