Feature: Check for cookbook name in metadata

  In order to avoid complications where a cookbook repository name differs from the cookbook name
  As a developer
  I want to set the cookbook name within the metadata

  Scenario: Name specified in metadata
    Given a cookbook with metadata that specifies the cookbook name
     When I check the cookbook
     Then the consider setting cookbook name warning 045 should not be displayed against the metadata file

  Scenario: Name not specified in metadata
    Given a cookbook with metadata that does not specify the cookbook name
     When I check the cookbook
     Then the consider setting cookbook name warning 045 should be displayed against the metadata file

  Scenario: No cookbook metadata
    Given a cookbook that does not have defined metadata
     When I check the cookbook
     Then the consider setting cookbook name warning 045 should be displayed against the metadata file
