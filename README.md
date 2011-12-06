# Food Critic

Food Critic is a lint tool for Chef cookbooks. It requires Ruby 1.9.3. It doesn't do very much at the moment.

# Building

    $ bundle install
    $ bundle exec rake

# Continuous Integration
[Food Critic on Travis CI](http://travis-ci.org/acrmp/foodcritic)

![Built on Travis](https://secure.travis-ci.org/acrmp/foodcritic.png?branch=master)

# License
MIT - see the accompanying [LICENSE](https://github.com/acrmp/foodcritic/blob/master/LICENSE) file for details.

# Changelog
To see what has changed in recent versions see the [CHANGELOG](https://github.com/acrmp/foodcritic/blob/master/CHANGELOG.md).
Food Critic follows the [Rubygems RationalVersioningPolicy](http://docs.rubygems.org/read/chapter/7).

# Contributing
Additional rules and bugfixes are welcome! Please fork and submit a pull request on an individual branch per change.

# Writing a new rule

The rules are [defined in a simple dsl here](https://github.com/acrmp/foodcritic/blob/master/lib/foodcritic/rules.rb).

## The recipe block
Each rule has a recipe block that defines the matching logic for the rule. The block accepts a
[Nokogiri](http://nokogiri.org/) document that contains the Ripper parsed representation of your recipe. You can see
what this looks like by calling `to_xml` on the AST document.

So given a recipe that contains a single log resource:

__examples/recipes/default.rb__

```ruby
log "Chef is the business"
```

And a rule that does nothing except print the AST document to stdout:

__rules.rb__

```ruby
rule "FC123", "Short description shown to the user" do
  description "A longer description with more information."
  recipe do |ast|
    puts ast.to_xml
  end
end
```

Then when you run foodcritic against the example recipe you will see the tree that represents the recipe as passed to
your rule.

__stdout__

    $ foodcritic example

```xml
<?xml version="1.0"?>
<opt>
  <stmts_add>
    <stmts_new/>
    <command>
      <ident value="log">
        <pos line="1" column="0"/>
      </ident>
      <args_add_block value="false">
        <args_add>
          <args_new/>
          <string_literal>
            <string_add>
              <string_content/>
              <tstring_content value="Chef is the business">
                <pos line="1" column="5"/>
              </tstring_content>
            </string_add>
          </string_literal>
        </args_add>
      </args_add_block>
    </command>
  </stmts_add>
</opt>
```

## Matching within the recipe block

You can use Nokogiri's great support for XPath or CSS selectors to match against statements within the tree.

So if you wanted to get all `tstring_content` nodes that contained the word 'Chef' like our log statement above you
could do something like the following within the recipe block:

__rules.rb__

```ruby
recipe do |ast|
  puts ast.xpath("//tstring_content[contains(@value, 'Chef')]").to_xml
  []
end
```

And the output will be something like:

__stdout__

```xml
<tstring_content value="Chef is the business">
  <pos line="1" column="5"/>
</tstring_content>
```

This node contains a `pos` child node that defines its location within the recipe. Now lets finish our rule by adding
the matched node to the list of matches, which ensures the user will see a warning.

__rules.rb__

```ruby
rule "FC123", "Short description shown to the user" do
  description "A longer description with more information."
  recipe do |ast|
    ast.xpath("//tstring_content[contains(@value, 'Chef')]").map{|resource| match(resource)}
  end
end
```

__stdout__

    $ foodcritic example
    FC123: Short description shown to the user: example/recipes/default.rb:1

That's it - have fun. Thanks!
