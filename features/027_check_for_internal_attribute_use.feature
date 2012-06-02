Feature: Check for use of internal attributes

  In order to avoid confusion about the expected state of a converged node
  As a developer
  I want to identify calls to 'internal' resource attributes

  Scenario Outline: Access of internal attributes
    Given a cookbook recipe that declares a <resource> resource with the <attribute> attribute set to <value>
    When I check the cookbook
    Then the resource sets internal attribute warning 027 should be <show_warning>

  Examples:
    | resource | attribute    | value              | show_warning |
    | service  | enabled      | true               | shown        |
    | service  | enabled      | false              | shown        |
    | service  | enabled      | [].include?('foo') | shown        |
    | service  | running      | true               | shown        |
    | service  | running      | false              | shown        |
    | service  | running      | [].include?('foo') | shown        |
    | service  | service_name | "foo"              | not shown    |
    | my_lwrp  | enabled      | true               | not shown    |
    | my_lwrp  | running      | true               | not shown    |
