Feature: Check for unrecognised resource attributes

  In order to identify typos in recipes without the need for a converge
  As a developer
  I want to identify use of standard resources with unrecognised attributes

  Scenario Outline: Unrecognised attribute declared on built-in resource
    Given a recipe that declares a <type> resource with these attributes: <attributes>
    When I check the cookbook
    Then the unrecognised attribute warning 009 should be <shown>
  Examples:
    | type    | attributes                  | shown |
    | file    | punter,group,mode,action    | true  |
    | file    | owner,group,rights,action   | false |
    | file    | owner,group,mode,action     | false |
    | file    | action,retries              | false |
    | group   | gid                         | false |
    | group   | gid,membranes               | true  |
    | package | version,action,options      | false |
    | package | verison,action,options      | true  |

  Scenario: Resource declared using recognised attributes
    Given a recipe that declares a resource with standard attributes
    When I check the cookbook
    Then the unrecognised attribute warning 009 should not be displayed

  Scenario: LWRP Resource
    Given a recipe that declares a user-defined resource
    When I check the cookbook
    Then the unrecognised attribute warning 009 should not be displayed
     And no error should have occurred

  Scenario: Resource declared with only a name attribute
    Given a recipe that declares a resource with only a name attribute
    When I check the cookbook
    Then the unrecognised attribute warning 009 should not be displayed

  Scenario: Unrecognised attribute on recipe with multiple resources of the same type
    Given a recipe that declares multiple resources of the same type of which one has a bad attribute
    When I check the cookbook
    Then the unrecognised attribute warning 009 should be displayed against the correct resource

  Scenario: Resource with conditional attributes
    Given a recipe that declares a resource with recognised attributes and a conditional execution ruby block
     When I check the cookbook
     Then the unrecognised attribute warning 009 should not be displayed

  Scenario: Resource with nested block
    Given a recipe that declares a resource with recognised attributes and a nested block
     When I check the cookbook
     Then the unrecognised attribute warning 009 should not be displayed

  Scenario: Resource with attribute method call
    Given a recipe that declares a resource with an attribute value set to the result of a method call
     When I check the cookbook
     Then the unrecognised attribute warning 009 should not be displayed

  Scenario Outline: Install package with yum specifying architecture
    Given a recipe that installs a package with yum specifying the architecture
     When I check the cookbook specifying <version> as the Chef version
     Then the unrecognised attribute warning 009 should be <shown>
  Examples:
    | version | shown |
    | 0.8.14  | true  |
    | 0.9.6   | true  |
    | 0.9.8   | false |

  Scenario Outline: Retry a resource on failure
    Given a recipe that installs a gem with 5 retries
     When I check the cookbook specifying <version> as the Chef version
     Then the unrecognised attribute warning 009 should be <shown>
  Examples:
    | version | shown |
    | 0.8.16  | true  |
    | 0.9.0   | true  |
    | 0.10.2  | true  |
    | 0.10.4  | false |
