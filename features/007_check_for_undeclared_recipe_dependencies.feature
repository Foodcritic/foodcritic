Feature: Check for undeclared recipe dependencies

  In order to prevent failure of my Chef run due to a missing cookbook
  As a developer
  I want to identify included recipes that are not expressed in cookbook metadata

  Scenario Outline: Cookbook includes undeclared recipe dependency
    Given a cookbook recipe that includes an undeclared recipe dependency <qualifiers>
    When I check the cookbook
    Then the undeclared dependency warning 007 should be displayed
  Examples:
    | qualifiers                |
    |                           |
    | with parentheses          |
    | unscoped                  |
    | unscoped with parentheses |

  Scenario: Cookbook includes recipe via expression
    Given a cookbook recipe that includes a recipe name from an expression
    When I check the cookbook
    Then the undeclared dependency warning 007 should not be displayed

  Scenario Outline: Cookbook includes recipe via expression (embedded)
    Given a cookbook recipe that includes a recipe name from an embedded expression <recipe_expression>
    When I check the cookbook
    Then the undeclared dependency warning 007 should not be displayed
  Examples:
    | recipe_expression              |
    | foo::#{node['foo']['fighter']} |
    | #{cookbook_name}::other        |
    | #{cbk}_other::other            |

  Scenario Outline: Declared dependencies
    Given a cookbook recipe that includes <dependency_type>
    When I check the cookbook
    Then the undeclared dependency warning 007 should not be displayed
  Examples:
    | dependency_type                                         |
    | a declared recipe dependency                            |
    | a declared recipe dependency unscoped                   |
    | several declared recipe dependencies - block            |
    | several declared recipe dependencies - brace            |
    | a local recipe                                          |
    | a local recipe where the directory is differently named |

  Scenario: Cookbook includes mix of declared and undeclared recipe dependencies
    Given a cookbook recipe that includes both declared and undeclared recipe dependencies
    When I check the cookbook
    Then the undeclared dependency warning 007 should be displayed only for the undeclared dependencies

  Scenario: Cookbook has no metadata file
    Given a cookbook that does not have defined metadata
    When I check the cookbook
    Then the undeclared dependency warning 007 should not be displayed
     And no error should have occurred
