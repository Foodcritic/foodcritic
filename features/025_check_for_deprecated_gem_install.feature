Feature: Check for deprecated gem install

  In order to be clear and concise in my Chef recipes
  As a developer
  I want to use chef_gem in preference to manual compile-time gem install

  Scenario: Normal gem install
    Given a cookbook recipe that installs a gem
     When I check the cookbook specifying 0.10.10 as the Chef version
     Then the prefer chef_gem to manual install warning 025 should not be displayed

  Scenario: Compile-time gem install
    Given a cookbook recipe that installs a gem at compile time using the deprecated syntax
     When I check the cookbook specifying 0.10.10 as the Chef version
     Then the prefer chef_gem to manual install warning 025 should be shown

  Scenario: Compile-time gem upgrade
    Given a cookbook recipe that upgrades a gem at compile time using the deprecated syntax
     When I check the cookbook specifying 0.10.10 as the Chef version
     Then the prefer chef_gem to manual install warning 025 should be shown

  Scenario: Compile-time gem install - multiple from array
    Given a cookbook recipe that installs multiple gems from an array at compile time using the deprecated syntax
     When I check the cookbook specifying 0.10.10 as the Chef version
     Then the prefer chef_gem to manual install warning 025 should be shown

  Scenario: Compile-time gem install - multiple from wordlist
    Given a cookbook recipe that installs multiple gems from a word list at compile time using the deprecated syntax
     When I check the cookbook specifying 0.10.10 as the Chef version
     Then the prefer chef_gem to manual install warning 025 should be shown
