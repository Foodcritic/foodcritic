Feature: Name should match cookbook dir name in metadata

  In order to avoid complications where a cookbook repository name differs from the cookbook name
  As a developer
  I want to set the cookbook name within the metadata

  Scenario: Name mismatched in metadata
    Given a cookbook with metadata that includes a mismatched cookbook name
     When I check the cookbook
     Then the name should match cookbook dir name warning 054 should be displayed against the metadata file

  Scenario: Name mismatched in metadata
    Given a cookbook with metadata that includes a matched cookbook name
     When I check the cookbook
     Then the name should match cookbook dir name warning 054 should not be displayed against the metadata file

  Scenario: Name matching in metadata in the cookbooks directory
    Given a cookbook with metadata that includes a matched cookbook name
     When I check the cookbook with dot as the argument
     Then the FC054 warning should not be displayed against the ./metadata.rb file
