Feature: Check for no maintainer email

  In order to be able to upload my cookbook
  As a developer
  I want to be notified when my cookbook metadata does not specify the maintainer email

  Scenario: Metadata without a maintainer email
    Given a cookbook with metadata that does not include a maintainer email
     When I check the cookbook
     Then the metadata missing maintainer email warning 056 should be shown against the metadata file

  Scenario: Metadata with a maintainer email
    Given a cookbook with metadata that includes a maintainer email
     When I check the cookbook
     Then the metadata missing maintainer email warning 056 should be not shown against the metadata file

  Scenario: Metadata with a maintainer email that is an expression
    Given a cookbook with metadata that includes a maintainer email expression
     When I check the cookbook
     Then the metadata missing maintainer email warning 056 should be not shown against the metadata file

  Scenario: Cookbook without metadata file
    Given a cookbook that does not have defined metadata
    When I check the cookbook
    Then the metadata missing maintainer email warning 056 should be not shown against the metadata file
