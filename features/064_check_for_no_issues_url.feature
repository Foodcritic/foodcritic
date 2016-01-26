Feature: Check for no issues_url

  In order to be able to share my cookbook on the Supermarket
  As a developer
  I want to be notified when my cookbook metadata does not specify the issues_url

  Scenario: Metadata without a issues_url
    Given a cookbook with metadata that does not include a issues_url keyword
     When I check the cookbook
     Then the metadata missing issues_url warning 064 should be shown against the metadata file

  Scenario: Metadata with a issues_url
    Given a cookbook with metadata that includes a issues_url keyword
     When I check the cookbook
     Then the metadata missing issues_url warning 064 should be not shown against the metadata file

  Scenario: Metadata with a issues_url that is an expression
    Given a cookbook with metadata that includes a issues_url expression
     When I check the cookbook
     Then the metadata missing issues_url warning 064 should be not shown against the metadata file

  Scenario: Cookbook without metadata file
    Given a cookbook that does not have defined metadata
    When I check the cookbook
    Then the metadata missing issues_url warning 064 should be not shown against the metadata file
