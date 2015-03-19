Feature: Check for metadata using recommends keyword

  In order to ensure that recipe metadata is stable
  As a developer
  I want to identify metadata that is using unimplemented features whose definitions may change in the future

  Scenario: Metadata with the recommends keyword
    Given a cookbook with metadata that includes a recommends keyword
     When I check the cookbook
     Then the metadata using recommends warning 053 should be shown against the metadata file

  Scenario: Metadata without the recommends keyword
    Given a cookbook with metadata that does not include a recommends keyword
     When I check the cookbook
     Then the metadata using recommends warning 053 should be not shown against the metadata file
