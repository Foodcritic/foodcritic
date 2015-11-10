Feature: Defined cookbook version should be valid

  In order to ensure that recipe metadata is stable
  As a developer
  I want to identify metadata that does not define a valid verison for the cookbook

  Scenario: Metadata with the version keyword and a valid version
    Given a cookbook with metadata that includes the version keyword and a valid version string
     When I check the cookbook
     Then the metadata defines valid version warning 061 should not be displayed against the metadata file

  Scenario: Metadata with the version keyword and a valid version with double quotes
    Given a cookbook with metadata that includes the version keyword and a valid version string with double quotes
     When I check the cookbook
     Then the metadata defines valid version warning 061 should not be displayed against the metadata file

  Scenario: Metadata with the version keyword and a valid x.y version
    Given a cookbook with metadata that includes the version keyword and a valid x.y version string
     When I check the cookbook
     Then the metadata defines valid version warning 061 should not be displayed against the metadata file

  Scenario: Metadata without the version keyword
    Given a cookbook with metadata that does not include a version keyword
     When I check the cookbook
     Then the metadata defines valid version warning 061 should not be displayed against the metadata file

  Scenario: Metadata with the version keyword and an invalid version
    Given a cookbook with metadata that includes the version keyword and an invalid version string
     When I check the cookbook
     Then the metadata defines valid version warning 061 should be displayed against the metadata file

  Scenario: Metadata with the version keyword and an invalid single digit version
    Given a cookbook with metadata that includes the version keyword and an invalid single digit version string
     When I check the cookbook
     Then the metadata defines valid version warning 061 should be displayed against the metadata file

  Scenario: Metadata with the version keyword and an invalid 4 digit version
    Given a cookbook with metadata that includes the version keyword and an invalid 4 digit version string
     When I check the cookbook
     Then the metadata defines valid version warning 061 should be displayed against the metadata file

  Scenario: Metadata version that uses string interpolation' do
    Given a cookbook with a metadata version that uses string interpolation
     When I check the cookbook
     Then the metadata defines valid version warning 061 should not be displayed against the metadata file

  Scenario: Metadata version that is not a string literal' do
    Given a cookbook with a metadata version that is not a string literal
     When I check the cookbook
     Then the metadata defines valid version warning 061 should not be displayed against the metadata file
