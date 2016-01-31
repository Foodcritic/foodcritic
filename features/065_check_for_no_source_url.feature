Feature: Check for no source_url

  In order to be able to share my cookbook on the Supermarket
  As a developer
  I want to be notified when my cookbook metadata does not specify the source_url

  Scenario: Metadata without a source_url
    Given a cookbook with metadata that does not include a source_url keyword
     When I check the cookbook
     Then the metadata missing source_url warning 065 should be shown against the metadata file

  Scenario: Metadata with a source_url
    Given a cookbook with metadata that includes a source_url keyword
     When I check the cookbook
     Then the metadata missing source_url warning 065 should be not shown against the metadata file

  Scenario: Metadata with a source_url that is an expression
    Given a cookbook with metadata that includes a source_url expression
     When I check the cookbook
     Then the metadata missing source_url warning 065 should be not shown against the metadata file

  Scenario: Cookbook without metadata file
    Given a cookbook that does not have defined metadata
    When I check the cookbook
    Then the metadata missing source_url warning 065 should be not shown against the metadata file
