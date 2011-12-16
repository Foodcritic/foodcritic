Feature: Check for deprecated README format

  In order to ensure that my cookbook README renders nicely on the Opscode Community site
  As a developer
  I want to identify if my cookbook is using an older-style RDoc format that needs converting

  Scenario: Cookbook missing RDoc formatted README
    Given a cookbook that does not have a README at all
    When I check the cookbook
    Then the deprecated format warning 012 should not be displayed against the README.rdoc file

  Scenario: Cookbook has RDoc formatted README
    Given a cookbook that has a README in RDoc format
    When I check the cookbook
    Then the deprecated format warning 012 should be displayed against the README.rdoc file

  Scenario: Cookbook has an alternatively formatted README
    Given a cookbook that has a README in markdown format
    When I check the cookbook
    Then the deprecated format warning 012 should not be displayed against the README.rdoc file