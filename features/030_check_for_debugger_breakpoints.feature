Feature: Check for debugger breakpoints

  In order to avoid halting a converge
  As a developer
  I want to identify debugger breakpoints that have not been removed

  Scenario Outline: Debugger breakpoints
    Given a cookbook with a <component> that <includes> a breakpoint
    When I check the cookbook
    Then the debugger breakpoint warning 030 should be <show_warning> against the <component>

  Examples:
    | component | includes         | show_warning |
    | library   | does not include | not shown    |
    | library   | includes         | shown        |
    | metadata  | does not include | not shown    |
    | metadata  | includes         | shown        |
    | provider  | does not include | not shown    |
    | provider  | includes         | shown        |
    | recipe    | does not include | not shown    |
    | recipe    | includes         | shown        |
    | resource  | does not include | not shown    |
    | resource  | includes         | shown        |
    | template  | does not include | not shown    |
    | template  | includes         | shown        |
