Feature: Check for metadata using suggests keyword

  In order to ensure that recipe metadata is stable
  As a developer
  I want to identify metadata that is using unimplemented features whose definitions may change in the future

  Scenario: Metadata with the suggests keyword
    Given a cookbook with metadata that includes a suggests keyword
     When I check the cookbook
     Then the metadata using suggests warning 052 should be shown against the metadata file

  Scenario: Metadata without the suggests keyword
    Given a cookbook with metadata that does not include a suggests keyword
     When I check the cookbook
     Then the metadata using suggests warning 052 should be not shown against the metadata file
