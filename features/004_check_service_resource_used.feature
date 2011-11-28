Feature: Check for service commands within execute resources

  In order to control services in an idiomatic way
  As a developer
  I want to identify if service commands are called by execute resources rather than using the service resource

  Scenario: Execute resource starting a service via init.d
    Given a cookbook recipe that uses execute to start a service via init.d
    When I check the cookbook
    Then the service resource warning 004 should be displayed

  Scenario: Execute resource starting a service via service command
    Given a cookbook recipe that uses execute to start a service via the service command
    When I check the cookbook
    Then the service resource warning 004 should be displayed

  Scenario: Execute resource starting a service via the full path to the service command
    Given a cookbook recipe that uses execute to start a service via full path to the service command
    When I check the cookbook
    Then the service resource warning 004 should be displayed

  Scenario: Execute resource starting a service via init.d (multiple commands)
    Given a cookbook recipe that uses execute to sleep and then start a service via init.d
    When I check the cookbook
    Then the service resource warning 004 should be displayed

  Scenario: Execute resource not controlling a service
    Given a cookbook recipe that uses execute to list a directory
    When I check the cookbook
    Then the service resource warning 004 should not be displayed

  Scenario: Execute resource using name attribute
    Given a cookbok recipe that uses execute with a name attribute to start a service
     When I check the cookbook
    Then the service resource warning 004 should be displayed
