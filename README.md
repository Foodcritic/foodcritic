# Foodcritic

[![Build Status](https://travis-ci.org/acrmp/foodcritic.svg?branch=master)](https://travis-ci.org/acrmp/foodcritic) [![Gem Version](https://badge.fury.io/rb/foodcritic.svg)](http://badge.fury.io/rb/foodcritic)

Foodcritic is a code linting tool for writing better and safer Chef cookbooks that runs both as a command line tool and as a Rake task. Out of the box Foodcritic contains over 50 cookbook rules, and plugin system for writing your own rules.

## Basic Usage

```shell
$ gem install foodcritic
$ foodcritic my_cookbook_dir
```

## Documentation

The Foodcritic site at <http://foodcritic.io/> contains documentation for each of the rules as well as documentation on the API for writing your own rules.

## Requirements

- Ruby 2.2.2+

## Building Foodcritic

```
$ bundle install
$ bundle exec rake
```

## Testing Foodcritic

Foodcritic includes rspec tests of the application itself and cucumber tests for each of the included rules. Each of these tests can be run via rake

Running rspec tests:

```
$ bundle exec rake spec
```

Running cucumber tests:

```
$ bundle exec rake features
```

Running regression tests:

```
$ bundle exec rake 'spec[regression]'
```

## License

MIT - see the accompanying [LICENSE](https://github.com/acrmp/foodcritic/blob/master/LICENSE) file for details.

## Changelog

To see what has changed in recent versions see the [CHANGELOG](https://github.com/acrmp/foodcritic/blob/master/CHANGELOG.md). Foodcritic follows the [Rubygems Semantic Versioning Policy](http://guides.rubygems.org/patterns/#semantic-versioning).

## Contributing

Additional rules and bug fixes are welcome! Please fork and submit a pull request on an individual branch per change.
