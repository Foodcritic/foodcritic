Feature: Interactive console

  In order to more quickly develop new rules and support exploratory changes
  As a developer
  I want to have an interactive console (REPL) built-in

  Scenario: Command help
    Given I have installed the lint tool
     When I run it on the command line with the help option
     Then the usage text should include an option for launching a REPL

  Scenario: Add a new rule dynamically
    Given I have started the lint tool with the REPL enabled
     When I define a new rule
     Then the rule should be visible in the list of rules

  Scenario: Reset the rules
    Given I have started the lint tool with the REPL enabled
     When I define a new rule and reset the list of rules
     Then the rule should not be visible in the list of rules

  Scenario: List DSL methods
    Given I have started the lint tool with the REPL enabled
     When I define a new rule that includes a binding
     Then I should be able to see the list of helper DSL methods from inside the rule

  Scenario: View cookbook AST
    Given I have started the lint tool with the REPL enabled
     When I define a new rule that includes a binding
     Then I should be able to see the AST from inside the rule

  Scenario: View cookbook review
    Given I have started the lint tool with the REPL enabled
    When I define a new rule that includes a binding
     Then the review should include the matching rules