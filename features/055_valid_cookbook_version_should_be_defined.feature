Feature: Valid cookbook version should be defined

  In order to ensure that recipe metadata is stable
  As a developer
  I want to identify metadata that does not define a valid verison for the cookbook

  Scenario: Metadata with the version keyword and a valid version
    Given a cookbook with metadata that includes the version keyword and a valid version string
     When I check the cookbook
     Then the metadata defines valid version warning 055 should be not shown against the metadata file

  Scenario: Metadata without the version keyword
    Given a cookbook with metadata that does not include a version keyword
     When I check the cookbook
     Then the metadata defines valid version warning 055 should be shown against the metadata file

  Scenario: Metadata with the version keyword and an invalid version
    Given a cookbook with metadata that includes the version keyword and an invalid version string
     When I check the cookbook
     Then the metadata defines valid version warning 055 should be shown against the metadata file
