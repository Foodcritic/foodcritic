Feature: Check for markdown readme

  In order to ensure that my cookbook README renders nicely on the Opscode Community site
  As a developer
  I want to identify if my cookbook does not have a markdown formatted README

  Scenario: Cookbook missing markdown formatted README
    Given a cookbook that does not have a README at all
    When I check the cookbook
    Then the missing readme warning 011 should be displayed against the README.md file

  Scenario: Cookbook has markdown formatted README
    Given a cookbook that has a README in markdown format
    When I check the cookbook
    Then the missing readme warning 011 should not be displayed against the README.md file

  Scenario: Cookbook has an alternatively formatted README
    Given a cookbook that has a README in RDoc format
    When I check the cookbook
    Then the missing readme warning 011 should be displayed against the README.md file