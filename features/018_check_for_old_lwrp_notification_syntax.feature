Feature: Check for use of deprecated LWRP notification syntax

  In order to ensure LWRP notifications continue to work
  As a developer
  I want to identify when a LWRP notification uses the deprecated syntax

  Scenario: LWRP with no notifications
    Given a cookbook that contains a LWRP that does not trigger notifications
    When I check the cookbook
    Then the LWRP uses deprecated notification syntax warning 018 should not be displayed against the provider file

  Scenario: LWRP with deprecated notification syntax
    Given a cookbook that contains a LWRP that uses the deprecated notification syntax
    When I check the cookbook
    Then the LWRP uses deprecated notification syntax warning 018 should be displayed against the provider file

  Scenario: LWRP with deprecated notification syntax (class variable)
    Given a cookbook that contains a LWRP that uses the deprecated notification syntax with a class variable
    When I check the cookbook
    Then the LWRP uses deprecated notification syntax warning 018 should be displayed against the provider file

  Scenario: LWRP with current notification syntax
    Given a cookbook that contains a LWRP that uses the current notification syntax
    When I check the cookbook
    Then the LWRP uses deprecated notification syntax warning 018 should not be displayed against the provider file