Feature: Individual file

  In order to get even faster feedback on changes to cookbooks
  As a developer
  I want to lint individual files in a cookbook

  Scenario: Linting an individual recipe shows warnings only from that file
    Given a cookbook with a single recipe that reads node attributes via symbols,strings
      And a cookbook that declares normal attributes via symbols
     When I check the recipe
     Then the attribute consistency warning 019 should be displayed for the recipe
      And the attribute consistency warning 019 should not be displayed for the attributes

  Scenario: Linting an individual role
    Given a roles directory
      And it contains a role file webserver.rb that defines the role name "apache"
      And it contains a role file database.rb that defines the role name "postgresql"
     When I check the webserver role only
     Then the role name does not match file name warning 049 should be shown against the webserver role
      And the role name does not match file name warning 049 should not be shown against the database role

  Scenario: Linting an individual environment
    Given an environments directory
      And it contains an environment file production_eu.rb that defines the environment name "production (eu-west-1)"
      And it contains an environment file production_us.rb that defines the environment name "production (us-east-1)"
     When I check the eu environment file only
     Then the invalid environment name warning 050 should be shown against the eu environment
      And the invalid environment name warning 050 should not be shown against the us environment
