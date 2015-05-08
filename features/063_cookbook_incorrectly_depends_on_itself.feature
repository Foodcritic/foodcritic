Feature: Check for metadata using suggests keyword

  In order to avoid pathological depsolving issues
  As a developer
  I want to identify cookboks that depend on themselves and remove that (unnecessary) dependency

  Scenario: Metadata with self dependency
    Given a cookbook with metadata that includes a self dependency
     When I check the cookbook
     Then the metadata with self dependency warning 063 should be shown against the metadata file

  Scenario: Metadata without self depenency
    Given a cookbook with metadata that does not include a self dependency
     When I check the cookbook
     Then the metadata with self dependency warning 063 should be not shown against the metadata file
