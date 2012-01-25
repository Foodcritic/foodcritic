Feature: Check for dodgy provider conditions

  In order to ensure that resources are declared as intended within a resource provider
  As a developer
  I want to identify resource conditions that will be checked only for the first resource

  Scenario: Provider with no condition
    Given a cookbook that contains a LWRP that declares a resource with no condition
    When I check the cookbook
    Then the dodgy resource condition warning 021 should not be displayed against the provider file

  Scenario Outline: Provider conditions
    Given a cookbook that contains a LWRP that declares a resource called <name> with the condition <condition>
    When I check the cookbook
    Then the dodgy resource condition warning 021 <show_warning> be displayed against the provider file

  Examples:
    | name                               | condition                                                  | show_warning |
    | "create_site"                      | not_if { ::File.exists?("/tmp/fixed-path")}                | should not   |
    | "create_site"                      | not_if { ::File.exists?("/tmp/#{new_resource.name}")}      | should       |
    | "create_site_#{new_resource.name}" | not_if { ::File.exists?("/tmp/#{new_resource.name}")}      | should not   |
    | "create_site"                      | only_if { ::File.exists?("/tmp/#{new_resource.name}")}     | should       |
    | "create_site_#{new_resource.name}" | only_if { ::File.exists?("/tmp/#{new_resource.name}")}     | should not   |
    | "create_site"                      | only_if "[ ! -f \"/tmp/#{new_resource.name}\" ]"           | should       |
    | "create_site"                      | not_if "[ -f \"/tmp/#{new_resource.name}\" ]"              | should       |
    | "create_site_#{new_resource.name}" | not_if "[ -f \"/tmp/#{new_resource.name}\" ]"              | should not   |
    | "create_site"                      | only_if do ::File.exists?("/tmp/#{new_resource.name}") end | should       |
    | "create_site_#{new_resource.name}" | only_if do ::File.exists?("/tmp/#{new_resource.name}") end | should not   |
