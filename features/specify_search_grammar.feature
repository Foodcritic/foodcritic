Feature: Specify search grammar

In order to allow the use of alternate search grammars when validating search syntax
As a developer
I want to be able to specify the grammar to use as a command line option

  Scenario: No grammar passed
    Given a cookbook recipe that attempts to perform a search with invalid syntax
    When I check the cookbook
    Then the invalid search syntax warning 010 should be displayed

  Scenario: Missing grammar passed
    Given a cookbook recipe that attempts to perform a search with invalid syntax
    When I check the cookbook specifying a search grammar that does not exist
    Then the check should abort with an error

  Scenario: Invalid grammar passed
    Given a cookbook recipe that attempts to perform a search with invalid syntax
    When I check the cookbook specifying a search grammar that is not in treetop format
    Then the check should abort with an error

  Scenario: Valid grammar passed
    Given a cookbook recipe that attempts to perform a search with invalid syntax
    When I check the cookbook specifying a search grammar that is a valid treetop grammar
    Then the invalid search syntax warning 010 should be displayed
