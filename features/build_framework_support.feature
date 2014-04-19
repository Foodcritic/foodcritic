@build
Feature: Build framework support

In order to make it as easy as possible to lint my cookbook
As a developer
I want to be able to invoke the lint tool from my build

  Scenario: List rake tasks
    Given a cookbook that has a Gemfile that includes rake and foodcritic
      And a Rakefile that defines a lint task with no block
     When I list the available build tasks
     Then the lint task will be listed

  Scenario: List rake tasks - modified name
    Given a cookbook that has a Gemfile that includes rake and foodcritic
      And a Rakefile that defines a lint task specifying a different name
     When I list the available build tasks
     Then the lint task will be listed under the different name

  Scenario Outline: Rakefile with no lint task
    Given a cookbook that has <problems> problems
      And the cookbook has a Gemfile that includes rake and foodcritic
      And a Rakefile that defines no lint task
     When I run the build
     Then the build will <build_outcome> with no warnings
  Examples:
    | problems | build_outcome |
    | no       | succeed       |
    | style    | succeed       |

  Scenario Outline: Lint task with no block
    Given a cookbook that has <problems> problems
      And the cookbook has a Gemfile that includes rake and foodcritic
      And a Rakefile that defines a lint task with no block
     When I run the build
     Then the build will <build_outcome> with warnings <warnings>
  Examples:
    | problems           | build_outcome | warnings    |
    | no                 | succeed       |             |
    | style              | succeed       | FC002       |
    | correctness        | fail          | FC006       |
    | style,correctness  | fail          | FC002,FC006 |

  Scenario Outline: Lint task with empty block
    Given a cookbook that has <problems> problems
      And the cookbook has a Gemfile that includes rake and foodcritic
      And a Rakefile that defines a lint task with an empty block
     When I run the build
     Then the build will <build_outcome> with warnings <warnings>
  Examples:
    | problems           | build_outcome | warnings    |
    | no                 | succeed       |             |
    | style              | succeed       | FC002       |
    | style,correctness  | fail          | FC002,FC006 |

  Scenario Outline: Specify rule tags to fail on
    Given a cookbook that has <problems> problems
      And the cookbook has a Gemfile that includes rake and foodcritic
      And a Rakefile that defines a lint task with a block setting options to <options>
     When I run the build
     Then the build will <build_outcome> with warnings <warnings>
  Examples:
    | problems           | options                                      | build_outcome | warnings    |
    | no                 |                                              | succeed       |             |
    | style,correctness  | {:fail_tags => []}                           | succeed       | FC002,FC006 |
    | correctness        | {:fail_tags => ['correctness']}              | fail          | FC006       |
    | style              | {:fail_tags => ['correctness,style']}        | fail          | FC002       |
    | style,correctness  | {:fail_tags => [], :tags => ['correctness']} | succeed       | FC006       |

  @context
  Scenario: Specify that contexts should be shown
    Given a cookbook with a single recipe that reads node attributes via symbols,strings
      And the cookbook has a Gemfile that includes rake and foodcritic
      And a Rakefile that defines a lint task with a block setting options to {:context => true}
      When I run the build
      Then the recipe filename should be displayed
      And the attribute consistency warning 019 should be displayed below
      And the line number and line of code that triggered the warning should be displayed

  Scenario Outline: Specify paths to lint
    Given a cookbook that has <problems> problems
      And the cookbook has a Gemfile that includes rake and foodcritic
      And a Rakefile that defines a lint task specifying files to lint as <files>
     When I run the build
     Then the build will <build_outcome> with warnings <warnings>
  Examples:
    | problems     | files                                       | build_outcome | warnings |
    | no           | ['recipes/default.rb']                      | succeed       |          |
    | correctness  | ['recipes/default.rb']                      | fail          | FC006    |
    | no           | ['recipes/default.rb', 'recipes/server.rb'] | succeed       |          |
    | correctness  | ['recipes/default.rb', 'recipes/server.rb'] | fail          | FC006    |

  Scenario: Exclude tests
    Given a cookbook that has style problems
      And the cookbook has a Gemfile that includes rake and foodcritic
      And a Rakefile that defines a lint task with no block
      And unit tests under a top-level test directory
     When I run the build
     Then no warnings will be displayed against the tests
      And the build will succeed with warnings FC002

  Scenario: Exclude vendored gems
    Given a cookbook that has style problems
      And the cookbook has a Gemfile that includes rake and foodcritic
      And a Rakefile that defines a lint task with no block
      And the gems have been vendored
     When I run the build
     Then no warnings will be displayed against the tests
      And the build will succeed with warnings FC002
