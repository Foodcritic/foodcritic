Feature: Check for incorrect platform method usage

  In order to avoid running code intended for another platform
  As a developer
  I want to identify conditionals that wrongly use node.platform?

  Scenario Outline: Platform conditionals
    Given a cookbook recipe that wraps a platform-specific resource in a <conditional> conditional
    When I check the cookbook
    Then the incorrect platform usage warning 028 should be <show_warning>

  Examples:
    | conditional                         | show_warning |
    | platform? 'linux'                   | not shown    |
    | platform?('linux')                  | not shown    |
    | platform?('linux', 'mac_os_x')      | not shown    |
    | node.platform? 'linux'              | shown        |
    | node.platform?('linux')             | shown        |
    | node.platform?('linux', 'mac_os_x') | shown        |
    | node.platform == 'linux'            | not shown    |
