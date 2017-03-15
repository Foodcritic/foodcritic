Feature: Check for no chef_version metadata

  In order to be clearly specify chef version compatibility to users
  As a developer
  I want to be notified when my cookbook metadata does not specify the chef_version

  Scenario: Metadata without a chef_version
    Given a cookbook with metadata that does not include a chef_version keyword
     When I check the cookbook
     Then the metadata missing chef_version warning 066 should be shown against the metadata file

  Scenario: Metadata with a chef_version
    Given a cookbook with metadata that includes a chef_version keyword
     When I check the cookbook
     Then the metadata missing chef_version warning 066 should be not shown against the metadata file

  Scenario: Cookbook without metadata file
    Given a cookbook that does not have defined metadata
    When I check the cookbook
    Then the metadata missing chef_version warning 066 should be not shown against the metadata file
