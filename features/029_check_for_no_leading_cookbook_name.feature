Feature: Check for no leading cookbook name

  In order to ensure cookbook recipes are correctly listed
  As a developer
  I want to identify recipes defined in metadata that do not include the leading cookbook name

  Scenario Outline: Recipe declaration in metadata
    Given a cookbook with metadata that declares a recipe with <declaration>
    When I check the cookbook
    Then the no leading cookbook name warning 029 should be <show_warning>

  Examples:
    | declaration                                     | show_warning |
    | recipe "example", "Installs Example"            | not shown    |
    | recipe "example::default", "Installs Example"   | not shown    |
    | recipe "default", "Installs Example"            | shown        |
    | recipe my_var, "Installs Example"               | not shown    |
    | recipe "#{my_var}::default", "Installs Example" | not shown    |
