### How can I prevent certain warnings from being shown?

You can include or exclude rules to apply using the `--tags` argument to
foodcritic. The tag expressions you can specify follow the same syntax as that
used in Cucumber - see the Cucumber wiki page below for details.

* [https://github.com/cucumber/cucumber/wiki/tags](https://github.com/cucumber/cucumber/wiki/tags)

For example if you don't care about `style` warnings you could run foodcritic
like so:

    $ foodcritic --tags ~style cookbooks

Each rule has an implicit tag so you can exclude individual rules by rule code:

    $ foodcritic --tags ~FC002 cookbooks

### Foodcritic dies with 'cannot load such file -- readline (LoadError)'

This is because your current Ruby has not been installed with Readline. If you
are using RVM you can follow the instructions on the RVM site to resolve this:

* [http://beginrescueend.com/packages/readline/](http://beginrescueend.com/packages/readline/)

