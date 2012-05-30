## 1.3.0 (21st May, 2012)

Features:

  - [FC026: Conditional execution block attribute contains only string](http://acrmp.github.com/foodcritic/#FC026)
    rule added
    ([related issue](https://github.com/acrmp/foodcritic/issues/30)).
    Thanks to @mkocher for proposing this rule.
  - Foodcritic now accepts multiple cookbook paths as arguments and supports
    linting of individual files only. Big thanks to @cgriego for these changes.
    These lay the groundwork for his new
    [guard-foodcritic](https://github.com/cgriego/guard-foodcritic) project.

Bugfixes:

  - [FC003: Check whether you are running with chef server before using server-specific features](http://acrmp.github.com/foodcritic/#FC003)
    would still warn if solo was checked for as a string
    ([related issue](https://github.com/acrmp/foodcritic/issues/26)).
    Thanks to @miketheman for identifying and fixing this issue.
  - [FC019: Access node attributes in a consistent manner](http://acrmp.github.com/foodcritic/#FC019)
    would warn when the node object had been re-opened for extension
    ([related issue](https://github.com/acrmp/foodcritic/issues/22)).
    Thanks @jaymzh.
  - [FC020: Conditional execution string attribute looks like Ruby](http://acrmp.github.com/foodcritic/#FC020)
    updated to not warn against strings that appear to contain file paths or Windows `net use`
    ([related issue](https://github.com/acrmp/foodcritic/issues/30)).
    Thanks @eherot and @mconigliaro.
  - [FC022: Resource condition within loop may not behave as expected](http://acrmp.github.com/foodcritic/#FC022)
    would warn incorrectly if the resource name was set directly to the block
    variable rather than being a string expression
    ([related issue](https://github.com/acrmp/foodcritic/issues/29)).
    Thanks @eherot.
  - The [resource_attributes](http://acrmp.github.com/foodcritic/#resource_attributes)
    API method has been updated to return the AST for resource notifications
    ([related issue](https://github.com/acrmp/foodcritic/issues/31)).
    Thanks @jonlives.

Other:

  - [Etsy have open-sourced their Foodcritic rules](https://github.com/etsy/foodcritic-rules).
    You should definitely check these out.
  - The effective Chef version for determining the rules to apply has been
    bumped to 0.10.10.

## 1.2.0 (21st April, 2012)

Features:

  - [FC025: Prefer chef_gem to compile-time gem install](http://acrmp.github.com/foodcritic/#FC025)
    rule added.
  - Rules can now declare which versions of Chef they `apply_to`. The new
    command line argument `-c` (`--chef-version`) should be used to specify the
    effective Chef version.

Bugfixes:

  - [FC001: Use strings in preference to symbols to access node attributes](http://acrmp.github.com/foodcritic/#FC001)
    could show false positives when using Chef search.
  - [FC001: Use strings in preference to symbols to access node attributes](http://acrmp.github.com/foodcritic/#FC001)
    would overlook the use of symbols to access node attributes when passing
    template variables.
  - [FC002: Avoid string interpolation where not required](http://acrmp.github.com/foodcritic/#FC002)
    fixed to no longer ignore the first keypair in a Hash
    ([related issue](https://github.com/acrmp/foodcritic/issues/24)).
    Thanks @Ips1975.
  - [FC004: Use a service resource to start and stop services](http://acrmp.github.com/foodcritic/#FC004)
    modified not to warn if the action is not supported by the `service`
    resource.
  - [FC005: Avoid repetition of resource declarations](http://acrmp.github.com/foodcritic/#FC005)
    modified not to warn when resources are branched within conditionals or
    provider actions.
  - [FC007: Ensure recipe dependencies are reflected in cookbook metadata](http://acrmp.github.com/foodcritic/#FC007)
    modified to ignore the use of `include_recipe` with embedded expressions.
  - [FC023: Prefer conditional attributes](http://acrmp.github.com/foodcritic/#FC023)
    modified not to warn if the conditional expression has an `else`.
  - The `resource_attributes` API method has been updated to return block
    attributes which were previously ignored
    ([related issue](https://github.com/acrmp/foodcritic/issues/23)).
    Thanks @jonlives.

## 1.1.0 (25th March, 2012)

Features:

  - [FC024: Consider adding platform equivalents](http://acrmp.github.com/foodcritic/#FC024) rule added.
  - When writing new rules it is no longer necessary to explicitly map
    matching AST nodes to matches. You can now just return the AST nodes.

Bugfixes:

  - The `cookbook_name` method now reflects the cookbook name if specified in
    metadata. This prevents a warning from being shown by
    [FC007: Ensure recipe dependencies are reflected in cookbook metadata](http://acrmp.github.com/foodcritic/#FC007)
    if the cookbook is in a differently named directory.
  - The `declared_dependencies` method previously would intermix version strings
    in the list of cookbook names.

Other:

  - Chef 0.10.10 will include a new DSL method for defining a `default_action`
    for resources. Rule
    [FC016: LWRP does not declare a default action](http://acrmp.github.com/foodcritic/#FC016)
    has been updated to recognise the DSL change.
  - Nokogiri dependency constraint changed to no longer lock to 1.5.0 as their
    next release should include the fix for custom XPath functions.

## 1.0.1 (15th March, 2012)

Bugfixes:

  - Nokogiri 1.5.1 and 1.5.2 cause a segfault so prevent their use until a fix
    is released
    ([related issue](https://github.com/acrmp/foodcritic/issues/18)).
    Thanks @miah.

## 1.0.0 (4th March, 2012)

Features:

  - New `-I` option added to specify the path to your own custom rules
    ([related issue](https://github.com/acrmp/foodcritic/issues/8)).
  - The
    [Rule API](https://github.com/acrmp/foodcritic/blob/v1.0.0/lib/foodcritic/api.rb)
    was previously not supported and subject to change without warning. From
    this release it will now follow the
    [same versioning policy](http://docs.rubygems.org/read/chapter/7) as the
    command line interface.
  - A version flag (--version or -V) has been added ([related issue](https://github.com/acrmp/foodcritic/issues/16)).

Bugfixes:

  - The evaluation of rule tags has been updated to be consistent with Cucumber.
    The major version number of foodcritic has been bumped to indicate that this
    is a breaking change. If you make use of tags (for example in a CI build)
    you may need to update your syntax. See the
    [related issue](https://github.com/acrmp/foodcritic/issues/11) for more
    information. Thanks @jaymzh.
  - [FC003: Check whether you are running with chef server before using
    server-specific features](http://acrmp.github.com/foodcritic/#FC003) has
    been updated to correctly identify the new version of chef-solo-search
    ([related issue](https://github.com/acrmp/foodcritic/issues/17)).

## 0.11.1 (29th February, 2012)

Bugfixes:

  - Foodcritic could fail to activate yajl-json in some circumstances, failing
    with a runtime error. Whether this occurred was dependent on the version of
    yajl-ruby activated by Chef, which would vary dependent on the other gems
    installed on the system. See the
    [related issue](https://github.com/acrmp/foodcritic/issues/14) for more
    information. Thanks @jaymzh for identifying the issue and striving to get
    Foodcritic playing well with Omnibus.

## 0.11.0 (22nd February, 2012)

Bugfixes:

  - Major bugfix to [FC006: Mode should be quoted or fully specified when setting file permissions](http://acrmp.github.com/foodcritic/#FC006). In earlier versions a four-digit literal file mode that set the first octet would not have been picked up by this rule ([related issue](https://github.com/acrmp/foodcritic/pull/9)). Thanks @aia for finding and fixing this bug. Check your cookbooks against FC006 after upgrading to see if you are affected.

## 0.10.0 (20th February, 2012)

Features:

  - Performance improvements.
  - [FC023: Prefer conditional attributes](http://acrmp.github.com/foodcritic/#FC023) rule added. Stolen from @ampledata with thanks.
  - New `-S` option added to allow an alternate search grammar to be specified.

Other:

  - Chef is no longer loaded at startup for performance reasons. Foodcritic now ships with Chef DSL metadata.

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
