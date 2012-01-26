## 0.9.0 (26th January, 2012)

Features:

  - New experimental `-C` option added to output context for rule matches.
  - [FC021: Resource condition in provider may not behave as expected](http://acrmp.github.com/foodcritic/#FC021) rule
    added.
  - [FC022: Resource condition within loop may not behave as expected](http://acrmp.github.com/foodcritic/#FC022) rule
    added.

Bugfixes:

  - [FC005: Avoid repetition of resource declarations](http://acrmp.github.com/foodcritic/#FC005) rule modified to only
    warn when there are at least three *consecutive* resources of the same type that could be 'rolled up' into a loop.
  - [FC016: LWRP does not declare a default action](http://acrmp.github.com/foodcritic/#FC016) rule restored. Thanks @stevendanna
  - [FC019: Access node attributes in a consistent manner](http://acrmp.github.com/foodcritic/#FC019) rule modified to no
    longer treat DSL mixin methods as auto-vivified attributes. Identification of least used access method should now be
    accurate.

Other:

  - [FC020: Conditional execution string attribute looks like Ruby](http://acrmp.github.com/foodcritic/#FC020) rule now
    grabs conditions from within single quotes.

## 0.8.1 (20th January, 2012)

Bugfixes:

  - [FC019: Access node attributes in a consistent manner](http://acrmp.github.com/foodcritic/#FC019) modified
    to avoid false positives on methods invoked on values in a Mash.

## 0.8.0 (19th January, 2012)

Features:

  - [FC019: Access node attributes in a consistent manner](http://acrmp.github.com/foodcritic/#FC019) rule added.
  - [FC020: Conditional execution string attribute looks like Ruby](http://acrmp.github.com/foodcritic/#FC020) rule added.

Other:

  - Rule 'FC016: LWRP does not declare a default action' was incorrectly checking the provider for a default action
    rather than the resource. Removed this rule temporarily to avoid showing false positives. A user has patched this
    and will be submitting a pull request shortly.

## 0.7.0 (31st December, 2011)

Features:

  - New `-f` option added to allow you to specify which warnings should result in the build being failed. See the new
    documentation on [using Foodcritic in Continuous Integration](http://acrmp.github.com/foodcritic/#ci) for more
    information.
  - New `-r` option added to drop you into the Pry REPL to interactively develop rules. See the updated documentation on
    [Writing a new rule](http://acrmp.github.com/foodcritic/#writing-a-new-rule) for more information.

Bugfixes:

  - [FC003: Check whether you are running with chef server before using server-specific features](http://acrmp.github.com/foodcritic/#FC003) rule
    modified to not warn if the [edelight chef-solo-search library](https://github.com/edelight/chef-solo-search) has been installed. Thanks @tobami.
  - [FC007: Ensure recipe dependencies are reflected in cookbook metadata](http://acrmp.github.com/foodcritic/#FC007) rule
    modified to flag undeclared dependencies against the offending file rather than metadata.rb.
  - Removed the unused description field from the rule dsl.

Other:

  - Project features now run much faster, running in-process by default. You can set an environment variable
    (`FC_FORK_PROCESS`) to specify that Cucumber runs should match the earlier behaviour and spawn a separate process
    using Aruba.

## 0.6.0 (18th December, 2011)

Features:

  - [FC001: Use strings in preference to symbols to access node attributes](http://acrmp.github.com/foodcritic/#FC001)
    rule added.
  - [FC004: Use a service resource to start and stop services](http://acrmp.github.com/foodcritic/#FC004) rule extended
    to recognise upstart and invoke-rc.d.
  - [FC011: Missing README in markdown format](http://acrmp.github.com/foodcritic/#FC011) rule added.
  - [FC012: Use Markdown for README rather than RDoc](http://acrmp.github.com/foodcritic/#FC012) rule added.
  - [FC013: Use file_cache_path rather than hard-coding tmp paths ](http://acrmp.github.com/foodcritic/#FC013) rule added.
  - [FC014: Consider extracting long ruby_block to library](http://acrmp.github.com/foodcritic/#FC014) rule added.
  - [FC015: Consider converting definition to a LWRP](http://acrmp.github.com/foodcritic/#FC015) rule added.
  - [FC016: LWRP does not declare a default action](http://acrmp.github.com/foodcritic/#FC016) rule added.
  - [FC017: LWRP does not notify when updated](http://acrmp.github.com/foodcritic/#FC017) rule added.
  - [FC018: LWRP uses deprecated notification syntax](http://acrmp.github.com/foodcritic/#FC018) rule added.

Bugfixes:

  - Ensure warnings are line sorted numerically. Commit eb1762fd0fbf99fa513783d7838ceac0147c37bc
  - [FC005: Avoid repetition of resource declarations](http://acrmp.github.com/foodcritic/#FC005) rule made less aggressive.

## 0.5.2 (15th December, 2011)

Bugfixes:

  - Fix JSON version range for compatibility with Bundler / Chef 0.10.6. ([related issue](https://github.com/acrmp/foodcritic/issues/6)). Thanks @dysinger.

## 0.5.1 (14th December, 2011)

Features:

  - Relaxed Ruby version constraint so we can run on 1.9.2 ([related issue](https://github.com/acrmp/foodcritic/issues/5)). Yay. Thanks @someara.

## 0.5.0 (13th December, 2011)

Features:

  - Added the ability to choose rules to apply via tags ([related issue](https://github.com/acrmp/foodcritic/issues/4)).
    This uses the same syntax as [Cucumber tag expressions](https://github.com/cucumber/cucumber/wiki/tags).
  - [FC010: Invalid search syntax](http://acrmp.github.com/foodcritic/#FC010) rule added.

## 0.4.0 (10th December, 2011)

Features:

  - [Spiffy new home page and documentation](http://acrmp.github.com/foodcritic/)
  - [FC008: Generated cookbook metadata needs updating](http://acrmp.github.com/foodcritic/#FC008) rule added.
  - [FC009: Resource attribute not recognised rule added](http://acrmp.github.com/foodcritic/#FC009).
    This adds a dependency on the Chef gem.
  - Performance improvement.

Bugfixes:

  - Fixed typo in FC004 feature description ([related issue](https://github.com/acrmp/foodcritic/issues/2)). Thanks @smith.
  - Prevented statements within nested resource blocks from being interpreted as resource attributes.

## 0.3.0 (4th December, 2011)

Features:

  - Significantly slower! But now you can write rules using [xpath or css selectors](http://nokogiri.org/).
  - FC006: File mode rule added.
  - FC007: Undeclared recipe dependencies rule added.

## 0.2.0 (1st December, 2011)

Bugfixes:

  - Removed 'FC001: Use symbols in preference to strings to access node attributes' until a policy mechanism is
  introduced ([related issue](https://github.com/acrmp/foodcritic/issues/1)). Thanks @jtimberman

## 0.1.0 (30th November, 2011)

Initial version.