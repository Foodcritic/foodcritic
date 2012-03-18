## Installing foodcritic
Ok - now we can move on to installing foodcritic itself. Foodcritic is distributed as a Rubygem - run the following commands to install it:

    $ rvm use 1.9.3
    $ gem install foodcritic

Great - that's it. You should now find you have a `foodcritic` command on your `PATH`. Run foodcritic to see what arguments it supports:

    foodcritic [cookbook_path]
        -r, --[no-]repl                  Drop into a REPL for interactive rule editing.
        -t, --tags TAGS                  Only check against rules with the specified tags.
        -f, --epic-fail TAGS             Fail the build if any of the specified tags are matched.
        -C, --[no-]context               Show lines matched against rather than the default summary.
        -I, --include PATH               Additional rule file path(s) to load.
        -S, --search-grammar PATH        Specify grammar to use when validating search syntax.
        -V, --version                    Display version.

Now for the fun part. Try running it against your favourite cookbook.
