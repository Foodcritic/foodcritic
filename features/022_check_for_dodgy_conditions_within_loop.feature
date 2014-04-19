Feature: Check for dodgy resource conditions within a loop

  In order to ensure that resources are declared as intended
  As a developer
  I want to identify resource conditions within a loop that will not be re-evaluated

  Scenario: Resource outside a loop
    Given a cookbook recipe that declares a resource called "feed_pet" with the condition outside a loop
    When I check the cookbook
    Then the dodgy resource condition warning 022 should not be displayed

  Scenario Outline: Resource within a loop
    Given a cookbook recipe that declares a resource called <name> with the condition <condition> in a loop
    When I check the cookbook
    Then the dodgy resource condition warning 022 <show_warning> be displayed

  Examples:
    | name                   | condition                                         | show_warning |
    | "feed_pet"             |                                                   | should not   |
    | "feed_pet"             | not_if { ::File.exists?("/tmp/fixed-path")}       | should not   |
    | "feed_pet"             | not_if { ::File.exists?("/tmp/#{pet_name}")}      | should       |
    | "feed_pet"             | only_if { ::File.exists?("/tmp/#{pet_name}")}     | should       |
    | "feed_pet"             | only_if { ::File.exists?(pet_name)}               | should       |
    | "feed_pet_#{pet_name}" | not_if { ::File.exists?("/tmp/#{pet_name}")}      | should not   |
    | "feed_pet"             | not_if { ::File.exists?("/tmp/#{unrelated_var}")} | should not   |
    | "feed_pet"             | only_if "[ -f \"/tmp/#{pet_name}\" ]"             | should       |
    | "feed_pet_#{pet_name}" | not_if "[ -f \"/tmp/#{pet_name}\" ]"              | should not   |
    | pet_name               | not_if "[ -f \"/tmp/#{pet_name}\" ]"              | should not   |

  Scenario: Resource within a multi-arg block
    Given a resource declared with a guard within a loop with multiple block arguments
    When I check the cookbook
    Then the dodgy resource condition warning 022 should not be shown

  Scenario: Resource guard contains a block
    Given a resource that declares a guard containing a block
     When I check the cookbook
     Then the dodgy resource condition warning 022 should not be shown

  Scenario: Loop in a definition
    Given a resource declared within a definition
    When I check the cookbook
    Then the dodgy resource condition warning 022 should not be shown
