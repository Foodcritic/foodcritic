Feature: Check for no supports metadata

  In order to clearly specify platform support to users
  As a developer
  I want to be notified when my cookbook metadata does not specify the platform supports

  Scenario: Metadata without a supports metadata
    Given a cookbook with metadata that does not include a supports keyword
     When I check the cookbook
     Then the metadata missing supports warning 067 should be shown against the metadata file

  Scenario: Metadata with a supports metadata
    Given a cookbook with metadata that includes a supports keyword
     When I check the cookbook
     Then the metadata missing supports warning 067 should be not shown against the metadata file

  Scenario: Cookbook without metadata file
    Given a cookbook that does not have defined metadata
    When I check the cookbook
    Then the metadata missing supports warning 067 should be not shown against the metadata file
