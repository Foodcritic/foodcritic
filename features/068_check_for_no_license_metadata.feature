Feature: Check for no license metadata

  In order to clearly specify cookbook licensing to consumers
  As a developer
  I want to be notified when my cookbook metadata does not specify the license

  Scenario: Metadata without a license
    Given a cookbook with metadata that does not include a license keyword
     When I check the cookbook
     Then the metadata missing license warning 068 should be shown against the metadata file

  Scenario: Metadata with a license
    Given a cookbook with metadata that includes a license keyword
     When I check the cookbook
     Then the metadata missing license warning 068 should be not shown against the metadata file

  Scenario: Cookbook without metadata file
    Given a cookbook that does not have defined metadata
    When I check the cookbook
    Then the metadata missing license warning 068 should be not shown against the metadata file
