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