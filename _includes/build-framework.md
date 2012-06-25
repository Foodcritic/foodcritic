As an alternative to invoking foodcritic directly as a command-line program,
you can also choose to run foodcritic from a build using Rake or Thor.

### Rake

Foodcritic has *unreleased* experimental support for
[Rake](http://rake.rubyforge.org/) included. With foodcritic and rake in your
`Gemfile` your `Rakefile` would look like this:

    require 'foodcritic'
    task :default => [:foodcritic]
    FoodCritic::Rake::LintTask.new

You can also pass a block when instantiating to configure the lint options:

    require 'foodcritic'
    task :default => [:foodcritic]
    FoodCritic::Rake::LintTask.new do |t|
      t.options = {:fail_tags => ['correctness']}
    end

### Thor

While Rake is the old grand-daddy of Ruby build tools, a number of people
prefer to use [Thor](https://github.com/wycats/thor).

Jamie Winsor has released the `thor-foodcritic` gem with some
[easy instructions to get started](https://github.com/reset/thor-foodcritic)
if you are using Thor for your build.
