In this contrived example we are going to add a new rule to raise a warning if a
recipe or provider declares a log resource that contains the word 'password'.

First, a word about how Foodcritic works. The rules are defined in a simple DSL
here:

* [https://github.com/acrmp/foodcritic/blob/master/lib/foodcritic/rules.rb](https://github.com/acrmp/foodcritic/blob/master/lib/foodcritic/rules.rb)

Each rule has a block that defines the matching logic for the rule. The block
accepts a [Nokogiri](http://nokogiri.org/) document that contains the Ripper
parsed representation of your recipe. Ripper is a very useful module that ships
with recent versions of Ruby allowing you to walk the tree of symbols
representing your program without actually having to eval it.

### Grab the source code
It's easiest to [fork the repository](http://help.github.com/fork-a-repo/) first
and then clone from the forked version. Browse to the foodcritic repository on
GitHub:

* [https://github.com/acrmp/foodcritic](https://github.com/acrmp/foodcritic)

Click the 'Fork' button in the top right-hand corner. Cool, now you have your
own copy of the repo.

    $ git clone https://you@github.com/you/foodcritic.git
    $ rvm use 1.9.3
    $ cd foodcritic
    $ git checkout -b log-contains-password
    Switched to a new branch 'log-contains-password'
    $ bundle install

### Run the foodcritic build

Before we make any code changes lets check that the existing code builds
successfully on our machine.

    $ bundle exec rake

### Add a new feature
Lets add a Cucumber feature to describe our new rule with a couple of scenarios:

    $ cat > features/123_check_for_log_with_password.feature <<EOF
    Feature: Check for log statements that contain passwords

    In order to prevent disclosure of credentials
    As a developer
    I want to identify when a log statement includes the word password

    Scenario: Log includes password
      Given a recipe that declares a log resource including the word password
      When I check the cookbook
      Then the log resource includes password warning 123 should be displayed

    Scenario: Log does not include password
      Given a recipe that declares a log resource that does not include the word password
      When I check the cookbook
      Then the log resource includes password warning 123 should not be displayed
    EOF

### Run Cucumber

Each of the lines in the scenario needs a matching step definition . If we run
cucumber against our new feature:

    $ bundle exec cucumber features/123_check_for_log_with_password.feature
    ...
    You can implement step definitions for undefined steps with these snippets:

    Given /^a recipe that declares a log resource including the word password$/ do
      pending # express the regexp above with the code you wish you had
    end

    Given /^a recipe that declares a log resource that does not include the word password$/ do
      pending # express the regexp above with the code you wish you had
    end

Cucumber is telling us that we need to implement the `Given` steps. The `When`
and `Then` steps have already been implemented for us.

### Implement a step definition

Lets implement the first `Given`, the one that creates a recipe that declares a
log resource with the word password.

    $ cat >> features/step_definitions/cookbook_steps.rb <<EOF

    Given 'a recipe that declares a log resource including the word password' do
      write_recipe %q{
        log "The secret password is: password1"
      }
    end
    EOF

Now lets run Cucumber. We expect it to fail at this stage.

    $ bundle exec cucumber features/123_check_for_log_with_password.feature
    ...
    Failing Scenarios:
    cucumber features/123_check_for_log_with_password.feature:7 # Scenario: Log includes password

Great, we have a failing test. Now we can set about implementing the rule.

### Ensure cucumber will recognise the new warning
In order for Cucumber to correctly recognise the new warning it needs to be
added to the `WARNINGS` hash in `support/command_helpers.rb`.

    $ cat <<EOF | git apply
    diff --git a/features/support/command_helpers.rb b/features/support/command_helpers.rb
    --- a/features/support/command_helpers.rb
    +++ b/features/support/command_helpers.rb
    @@ -31,3 +31,4 @@ module FoodCritic
           'FC022' => 'Resource condition within loop may not behave as expected',
    -      'FC023' => 'Prefer conditional attributes'
    +      'FC023' => 'Prefer conditional attributes',
    +      'FC123' => 'Log contains password'
         }
    EOF

### Implementing the rule
Lets use the very awesome [Pry REPL](http://pry.github.com/) to interactively
explore writing a new rule, much as we might use Shef for writing Chef recipes.

Run the build with `FC_REPL=true` and you will be dropped into the Pry REPL:

    $ FC_REPL=true bundle exec cucumber features/123_check_for_log_with_password.feature:7

### Add a new rule

First define a new placeholder rule:

    pry> rule "FC123", "Log contains password" do
      recipe do |ast|
        binding.pry
      end
    end

Check that it has been added to the list of rules:

    pry> puts rules

And exit, to be taken to the binding you declared above:

    pry> exit

### Listing the available DSL methods

A number of pre-canned DSL methods exist to help in writing rules. You can list
these by typing:

    pry> Api.instance_methods.sort

To see the documentation for one method in particular (here the
`included_recipes` method) type:

    pry> show-doc included_recipes

    From: foodcritic/lib/foodcritic/api.rb @ line 133:
    Number of lines: 4
    Owner: FoodCritic::Api
    Visibility: public
    Signature: included_recipes(ast)

    Retrieve the recipes that are included within the given recipe AST.

    param [Nokogiri::XML::Node] ast The recipe AST
    return [Hash] include_recipe nodes keyed by included recipe name

### Write an expression that matches your criteria

To view the XML representation of the AST, type:

    pry> puts ast

You can use Nokogiri's great support for XPath or CSS selectors to match against
statements within the tree. Lets try and write a XPath expression that will
match only the nodes you are interested in.

    pry> puts ast.xpath("//command[ident/@value='log']/descendant::tstring_content[contains(@value, 'password')]")
    <tstring_content value="The secret password is: password1">
      <pos line="1" column="5"/>
    </tstring_content>

### Flagging matches

For foodcritic to report your warning you currently need to specify them as
matches. You need to map a node in the AST that has a child `pos` node which
foodcritic can use to display the line number.

    pry> ast.xpath("//command[ident/@value='log']/descendant::tstring_content[contains(@value, 'password')]").map{|n| match(n)}
    => [{:matched=>"tstring_content", :line=>"1", :column=>"5"}]

### Update the rule definition

Now we have what we think is the matching expression lets update the rule definition:

    pry> cd ..
    pry> reset_rules
    pry> rule "FC123", "Log contains password" do
      tags %w{security}
      recipe do |ast|
        ast.xpath("//command[ident/@value='log']/descendant::tstring_content[contains(@value, 'password')]").map{|n| match(n)}
      end
    end
    pry> exit

And finally re-run the check against the newly redefined rule:

    pry> recheck
    pry> review
    => FC011: Missing README in markdown format: cookbooks/example/README.md:1
    FC123: Log contains password: cookbooks/example/recipes/default.rb:1

    pry> exit
    pry> exit
        When I check the cookbook                                               # features/step_definitions/cookbook_steps.rb:410
        Then the log resource includes password warning 123 should be displayed # features/step_definitions/cookbook_steps.rb:434

    1 scenario (1 passed)
    3 steps (3 passed)

### Next steps

Once the step definitions have been completed you need to:

* Think of other scenarios that you need to test. For this example you might
  consider that Chef allows you to log via direct calls to the Chef logger as
  well and modify your scenarios and rule definition to deal with this.
* Run the feature to confirm it passes on both Ruby 1.9.2 and 1.9.3 as there are
  AST differences between them.
* Run the complete build again.
* Push your changes to GitHub and open a pull request.

That's it - have fun. Thanks!
