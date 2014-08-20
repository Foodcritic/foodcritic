## 4.0.0 (12th June, 2014)

Features:

  - AST parsing is cached with a LRU cache, significantly reducing execution time
    ([related issue](https://github.com/acrmp/foodcritic/issues/200)).
    Thanks @dougbarth.
  - [FC001: Use strings in preference to symbols to access node attributes](http://foodcritic.io/#FC001)
    rule re-instated
    ([related issue](https://github.com/acrmp/foodcritic/issues/97)).
    Thanks @sethvargo.
  - Relaxed nokogiri and yajl-ruby dependencies for bundling with other gems
    ([related issue](https://github.com/acrmp/foodcritic/issues/217))
    ([related issue](https://github.com/acrmp/foodcritic/issues/197)).
    Thanks @lamont-granquist, @elgalu.
  - DSL metadata for Chef versions 11.6.2 through 11.10.4 added
    ([related issue](https://github.com/acrmp/foodcritic/issues/220)).
    Thanks @lamont-granquist.
  - Improved rake task output on failure
    ([related issue](https://github.com/acrmp/foodcritic/issues/190)).
    Thanks @mlafeldt.
  - Allow rake task description to be specified
    ([related issue](https://github.com/acrmp/foodcritic/issues/190)).
    Thanks @mlafeldt.
  - Allow the rake task to use context output
    ([related issue](https://github.com/acrmp/foodcritic/issues/204)).
    Thanks @docwhat.
  - Add support for excluding paths at the command line with `-X`
    ([related issue](https://github.com/acrmp/foodcritic/issues/207)).
    Thanks @juanje, @docwhat.

Bugfixes:

  - [FC003: Check whether you are running with chef server before using server-specific features](http://foodcritic.io/#FC003)
    would warn incorrectly against ternary expressions
    ([related issue](https://github.com/acrmp/foodcritic/issues/185)). Thanks @zts.
  - [FC006: Mode should be quoted or fully specified when setting file permissions](http://foodcritic.io/#FC006)
    would warn incorrectly if the mode was a reference to an array
    ([related issue](https://github.com/acrmp/foodcritic/issues/211)). Thanks @zts.
  - [FC022: Resource condition within loop may not behave as expected](http://foodcritic.io/#FC022)
    could warn incorrectly if the resource guard contained a loop
    ([related issue](https://github.com/acrmp/foodcritic/issues/69)). Thanks
    @jaymzh.
  - [FC022: Resource condition within loop may not behave as expected](http://foodcritic.io/#FC022)
    could warn incorrectly against definitions
    ([related issue](https://github.com/acrmp/foodcritic/issues/195)). Thanks
    @bpaquet.
  - [FC034: Unused template variables](http://foodcritic.io/#FC034)
    could warn incorrectly when different templates may be used based on platform.
  - [FC040: Execute resource used to run git commands](http://foodcritic.io/#FC040)
    would fail to warn for subsequent resources
    ([related issue](https://github.com/acrmp/foodcritic/issues/186)). Thanks
    @nkammah.
  - [FC047: Attribute assignment does not specify precedence](http://foodcritic.io/#FC047)
    would warn incorrectly on force attributes
    ([related issue](https://github.com/acrmp/foodcritic/issues/226)). Thanks
    @v-a.

Other:

  - Ruby 1.9.2 support has been removed.
  - The default DSL metadata version has been bumped to 11.10.4
    ([related issue](https://github.com/acrmp/foodcritic/issues/210)).
    Thanks @kmshultz.

## 3.0.3 (13th October, 2013)

Bugfixes:

  - [FC051: Template partials loop indefinitely](http://foodcritic.io/#FC051)
    would cause an error for partials included from a subdirectory or where the
    partial did not exist
    ([related issue](https://github.com/acrmp/foodcritic/issues/176)). Thanks
    @claco, @michaelglass.

## 3.0.2 (5th October, 2013)

Bugfixes:

  - [FC051: Template partials loop indefinitely](http://foodcritic.io/#FC051)
    can cause foodcritic to exit with an error on encountering a file that
    cannot be read as UTF-8. We now explicitly exclude `.DS_Store` and `*.swp`
    as a workaround
    ([related issue](https://github.com/acrmp/foodcritic/issues/172)). Thanks
    @tmatilai, @claco.
  - [FC022: Resource condition within loop may not behave as expected](http://foodcritic.io/#FC022)
    would warn incorrectly against loops where the block accepts more than one
    argument
    ([related issue](https://github.com/acrmp/foodcritic/issues/69)). Thanks
    @Ips1975, @jaymzh.

## 3.0.1 (25th September, 2013)

Other:

  - Rake version constraint removed to make packaging easier for users who
    deploy foodcritic alongside Omnibus Chef.

## 3.0.0 (14th September, 2013)

Features:

  - [FC047: Attribute assignment does not specify precedence](http://foodcritic.io/#FC047)
    rule added
    ([related issue](https://github.com/acrmp/foodcritic/issues/81)). Thanks
    @jtimberman, @miketheman.
  - [FC048: Prefer Mixlib::ShellOut](http://foodcritic.io/#FC048)
    rule added
    ([related issue](https://github.com/acrmp/foodcritic/issues/111)). Thanks
    @jaymzh.
  - [FC049: Role name does not match containing file name](http://foodcritic.io/#FC049)
    rule added
    ([related issue](https://github.com/acrmp/foodcritic/issues/19)). Thanks
    @jaymzh.
  - [FC050: Name includes invalid characters](http://foodcritic.io/#FC050)
    rule added.
  - [FC051: Template partials loop indefinitely](http://foodcritic.io/#FC051)
    rule added.
  - Added support for checking Chef environment and role files
    ([related issue](https://github.com/acrmp/foodcritic/issues/19)). Thanks
    @jaymzh.
  - Added metadata for Chef 11.6.0.
  - API methods `#field`, `#field_value` and `#templates_included` added.
  - The API now exposes access to whether individual warnings should be viewed
    as failures
    ([related issue](https://github.com/acrmp/foodcritic/issues/150)). Thanks
    @jamesdburgess.

Bugfixes:

  - [FC007: Ensure recipe dependencies are reflected in cookbook metadata](http://foodcritic.io/#FC007)
    would warn if specifying dependencies in a multi-line word list with leading whitespace
    ([related issue](https://github.com/acrmp/foodcritic/issues/160)). Thanks to
    @philk for identifying and fixing this issue.
  - [FC007: Ensure recipe dependencies are reflected in cookbook metadata](http://foodcritic.io/#FC007)
    would not warn if `include_recipe` used parentheses
    ([related issue](https://github.com/acrmp/foodcritic/issues/155)). Thanks
    @jamesdburgess.
  - [FC017: LWRP does not notify when updated](http://foodcritic.io/#FC017)
    would warn even if `converge_by` or `use_inline_resources` was used
    ([related issue](https://github.com/acrmp/foodcritic/issues/90)). Thanks
    @stevendanna, @nevir.
  - [FC017: LWRP does not notify when updated](http://foodcritic.io/#FC017)
    would not warn if any action within the provider notified. Updated to report
    against actions individually
    ([related issue](https://github.com/acrmp/foodcritic/issues/90)).
  - [FC019: Access node attributes in a consistent manner](http://foodcritic.io/#FC019)
    would warn incorrectly against `node.run_state`
    ([related issue](https://github.com/acrmp/foodcritic/issues/66)). Thanks
    @jtimberman.
  - [FC033: Missing template](http://foodcritic.io/#FC033)
    would warn if the template filename began with a dot
    ([related issue](https://github.com/acrmp/foodcritic/issues/165)). Thanks
    @eherot.
  - [FC034: Unused template variables](http://foodcritic.io/#FC034)
    would warn incorrectly if variables were used by partials
    ([related issue](https://github.com/acrmp/foodcritic/issues/140)). Thanks to
    @v-a for implementing initial support for partials.
  - [FC034: Unused template variables](http://foodcritic.io/#FC034)
    would not be shown against inferred templates.
  - [FC038: Invalid resource action](http://foodcritic.io/#FC038)
    would warn incorrectly for log resources that specified a `write` action
    ([related issue](https://github.com/acrmp/foodcritic/issues/154)). Thanks
    @sethvargo.
  - The foodcritic gem was missing a dependency on rake which broke
    thor-foodcritic
    ([related issue](https://github.com/acrmp/foodcritic/issues/157)). Thanks
    @douglaswth.
  - Template warnings should now be shown against the correct line number.
    Previously warnings were always shown against line 1
    ([related issue](https://github.com/acrmp/foodcritic/issues/102)). Thanks
    @juliandunn.
  - The `#declared_dependencies` API method could return duplicates for old
    versions of LibXML.
    ([related issue](https://github.com/acrmp/foodcritic/issues/163)). Thanks
    @danleyden.

Other:

  - This release introduces breaking changes to programmatic use of foodcritic.

## 2.2.0 (10th July, 2013)

Features:

  - Additional rules may now be shipped as gems. Files matching the path
    `foodcritic/rules/**/*.rb` will be loaded if the `--search-gems` option is
    specified
    ([related issue](https://github.com/acrmp/foodcritic/issues/143)). Thanks
    to @rteabeault for implementing this feature.
  - You can now control the rules applied to individual cookbooks by including
    a `.foodcritic` file at the root of your cookbook with the tags you want
    checked
    ([related issue](https://github.com/acrmp/foodcritic/issues/141)). Thanks
    to @sabat for implementing this feature.
  - The [project license](https://github.com/acrmp/foodcritic/blob/master/LICENSE)
    is now included in the built gem
    ([related issue](https://github.com/acrmp/foodcritic/issues/145)).
    Thanks @stefanor.
  - Foodcritic no longer uses the `rak` gem to generate output with context
    ([related issue](https://github.com/acrmp/foodcritic/issues/146)).
    Thanks to @stefanor for re-implementing context output to remove this
    dependency.
  - A man page is now included with foodcritic in
    [ronn-format](http://rtomayko.github.io/ronn/).
    Thanks @stefanor.

Bugfixes:

  - Definitions are now included in the files that are linted
    ([related issue](https://github.com/acrmp/foodcritic/issues/142)). Thanks
    @bpaquet.
  - [FC009: Resource attribute not recognised](http://acrmp.github.com/foodcritic/#FC009)
    would warn against Windows-specific resource attributes
    ([related issue](https://github.com/acrmp/foodcritic/issues/135)). Thanks
    @stormtrooperguy.
  - [FC011: Missing README in markdown format](http://acrmp.github.com/foodcritic/#FC011)
    was not shown when outputting with context enabled
    ([related issue](https://github.com/acrmp/foodcritic/issues/146)). Thanks
    @stefanor.
  - [FC014: Consider extracting long ruby_block to library](http://acrmp.github.com/foodcritic/#FC014)
    previously used the number of AST nodes to determine block length. This
    was a poor proxy for length and this rule has been updated to warn if the
    number of lines > 15
    ([related issue](https://github.com/acrmp/foodcritic/issues/130)). Thanks
    @adamjk-dev.
  - [FC014: Consider extracting long ruby_block to library](http://acrmp.github.com/foodcritic/#FC014)
    would warn against other blocks incorrectly
    ([related issue](https://github.com/acrmp/foodcritic/issues/130)). Thanks
    @adamjk-dev.
  - [FC014: Consider extracting long ruby_block to library](http://acrmp.github.com/foodcritic/#FC014)
    would raise an error if the ruby_block did not contain a nested `block`
    attribute
    ([related issue](https://github.com/acrmp/foodcritic/issues/139)). Thanks
    @stevendanna.
  - [FC033: Missing template](http://acrmp.github.com/foodcritic/#FC033)
    would warn when the template file did not have an erb extension
    ([related issue](https://github.com/acrmp/foodcritic/issues/131)). Thanks
    @nvwls.
  - [FC034: Unused template variables](http://acrmp.github.com/foodcritic/#FC034)
    would warn when the template file did not have an erb extension
    ([related issue](https://github.com/acrmp/foodcritic/issues/131)). Thanks
    @nvwls.

## 2.1.0 (17th April, 2013)

Features:

  - DSL metadata will now reflect the version of Chef selected with
    `--chef-version`. For example this means that
    [FC009: Resource attribute not recognised](http://acrmp.github.com/foodcritic/#FC009)
    will warn about attributes not present in the specified version of Chef.

Bugfixes:

  - [FC045: Consider setting cookbook name in metadata](http://acrmp.github.com/foodcritic/#FC045)
    would warn incorrectly and other rules would fail to work when activesupport
    had been loaded
    ([related issue](https://github.com/acrmp/foodcritic/issues/118)). This
    affected Berkshelf users. Thanks @scalp42 and @c-nolic.
  - Upgrade the version of Gherkin dependency to avoid deprecation warnings
    ([related issue](https://github.com/acrmp/foodcritic/pull/122)).
    Thanks @tmatilai.

Other:

  - Known to run on MRI 2.0.0 - added to Travis CI matrix.

## 2.0.1 (31st March, 2013)

Bugfixes:

  - Matches that should be ignored were not if the rule implementation used the
    `cookbook` block
    ([related issue](https://github.com/acrmp/foodcritic/issues/119)).
  - [FC033: Missing Template](http://acrmp.github.com/foodcritic/#FC033)
    would warn incorrectly when the template resource was nested within another
    resource
    ([related issue](https://github.com/acrmp/foodcritic/issues/96)).
    Thanks @justinforce.
  - The `#resource_attributes` API method now copes with nested resources.

## 2.0.0 (24th March, 2013)

Features

  - Support added for ignoring individual matches. To ignore a match add a
    comment to the affected line in your cookbook of the format `# ~FC006`
    ([related issue](https://github.com/acrmp/foodcritic/issues/119)).
    Big thanks to @grosser.
  - Command line help now specifies the tag to use to fail the build on any
    rule match
    ([related issue](https://github.com/acrmp/foodcritic/issues/108)).
    Thanks @grosser.
  - FC046: Attribute assignment uses assign unless nil
    rule added
    ([related issue](https://github.com/acrmp/foodcritic/issues/52)).
    Thanks @jaymzh.

Bugfixes:

  - [FC003: Check whether you are running with chef server before using server-specific features](http://acrmp.github.com/foodcritic/#FC003)
    updated to recognise checks that use return
    ([related issue](https://github.com/acrmp/foodcritic/issues/92)).
    Thanks @sethvargo, @miketheman.
  - [FC003: Check whether you are running with chef server before using server-specific features](http://acrmp.github.com/foodcritic/#FC003)
    updated to recognise checks that test for Chef Solo with alternation
    ([related issue](https://github.com/acrmp/foodcritic/issues/103)).
    Thanks @promisedlandt.
  - [FC017: LWRP does not notify when updated](http://acrmp.github.com/foodcritic/#FC017)
    modified to no longer warn when a notification is made without parentheses
    ([related issue](https://github.com/acrmp/foodcritic/issues/121)).
    Thanks @justinforce.
  - [FC019: Access node attributes in a consistent manner](http://acrmp.github.com/foodcritic/#FC019)
    would previously only show warnings for the first matching file.
  - [FC019: Access node attributes in a consistent manner](http://acrmp.github.com/foodcritic/#FC019)
    updated to avoid showing a false positive where a search is passed an
    argument based on a node attribute accessed with a string.
  - [FC019: Access node attributes in a consistent manner](http://acrmp.github.com/foodcritic/#FC019)
    updated to exclude specs, removing a source of false positives.
  - [FC019: Access node attributes in a consistent manner](http://acrmp.github.com/foodcritic/#FC019)
    fixed regression in var_ref handling.
  - [FC019: Access node attributes in a consistent manner](http://acrmp.github.com/foodcritic/#FC019)
    updated to not trigger on quoted symbols
    ([related issue](https://github.com/acrmp/foodcritic/issues/88)).
    Thanks @spheromak.
  - [FC024: Consider adding platform equivalents](http://acrmp.github.com/foodcritic/#FC024)
    updated to only warn about platform equivalents that are listed in the
    cookbook metadata
    ([related issue](https://github.com/acrmp/foodcritic/issues/59)).
    Thanks @tknerr.
  - [FC037: Invalid notification action](http://acrmp.github.com/foodcritic/#FC037)
    would cause foodcritic to halt with an error when a notification action was
    specified as an expression
    ([related issue](https://github.com/acrmp/foodcritic/issues/104)).
    Thanks @jaymzh.
  - [FC040: Execute resource used to run git commands](http://acrmp.github.com/foodcritic/#FC040)
    updated to not match if the git command cannot be expressed as a `git`
    resource.
    ([related issue](https://github.com/acrmp/foodcritic/pull/98)).
    Thanks @trobrock for raising this issue and implementing the fix.
  - [FC043: Prefer new notification syntax](http://acrmp.github.com/foodcritic/#FC043)
    updated to apply only to Chef versions >= 0.9.10
    ([related issue](https://github.com/acrmp/foodcritic/issues/114)).
    Thanks @iainbeeston.
  - [FC044: Avoid bare attribute keys](http://acrmp.github.com/foodcritic/#FC044)
    changed to not raise false positives against block variables
    ([related issue](https://github.com/acrmp/foodcritic/issues/105)).
    Thanks @jaymzh.

Other:

  - The `--repl` command line flag has been removed. This feature little used
    and was problematic for users attempting to use newer versions of pry or
    guard
    ([related issue](https://github.com/acrmp/foodcritic/issues/50)).
    Thanks @jperry, @miketheman, @jtimberman.
  - The `os_command?` api method has been removed.
  - The deprecated `cookbook_path` and `valid_path?` methods have been removed.
    This may cause breakage if you are using foodcritic programatically from
    Ruby. Please update your code to use the `cookbook_paths` and `valid_paths?`
    methods instead.
  - Added regression test for expected output against opscode-cookbooks. Run
    `bundle exec rake regressions` to perform this test.

## 1.7.0 (27th December, 2012)

Features

  - [FC038: Invalid resource action](http://acrmp.github.com/foodcritic/#FC038)
    rule added
    ([related issue](https://github.com/acrmp/foodcritic/issues/61)).
    Thanks @jaymzh.
  - [FC039: Node method cannot be accessed with key](http://acrmp.github.com/foodcritic/#FC039)
    rule added.
  - [FC040: Execute resource used to run git commands](http://acrmp.github.com/foodcritic/#FC040)
    rule stolen from Etsy rules (ETSY003)
    ([related issue](https://github.com/acrmp/foodcritic/issues/72)).
    Thanks @jonlives.
  - [FC041: Execute resource used to run curl or wget commands](http://acrmp.github.com/foodcritic/#FC041)
    rule stolen from Etsy rules (ETSY002)
    ([related issue](https://github.com/acrmp/foodcritic/issues/73)).
    Thanks @jonlives.
  - [FC042: Prefer include_recipe](http://acrmp.github.com/foodcritic/#FC042)
    rule added
    ([related issue](https://github.com/acrmp/foodcritic/pull/77)).
    Thanks @pwelch.
  - [FC043: Prefer new notification syntax](http://acrmp.github.com/foodcritic/#FC043)
    rule added
    ([related issue](https://github.com/acrmp/foodcritic/issues/80)).
    Thanks @jtimberman.
  - [FC044: Avoid bare attribute keys](http://acrmp.github.com/foodcritic/#FC044)
    rule added
    ([related issue](https://github.com/acrmp/foodcritic/issues/75)).
    Thanks @jtimberman.
  - [FC045: Consider setting cookbook name in metadata](http://acrmp.github.com/foodcritic/#FC045)
    rule added
    ([related issue](https://github.com/acrmp/foodcritic/issues/64)).
    Thanks @miketheman.
  - Linter `#check` method no longer requires options to be explicitly passed if
    you are using the defaults
    ([related issue](https://github.com/acrmp/foodcritic/pull/71)).
    Thanks @kreynolds.

Bugfixes:

  - Bump version of Nokogiri to
    [fix installation failure on Ubuntu 12.10](https://github.com/sparklemotion/nokogiri/issues/680)
    ([related issue](https://github.com/acrmp/foodcritic/issues/83)).
    Thanks @dracoater.
  - Support added for quoted symbols as notification actions
    ([related issue](https://github.com/acrmp/foodcritic/pull/94)).
    Thanks @ohm.
  - Add `spec/**/*` and `features/**/*` to default rake task `:exclude_paths`
    ([related issue](https://github.com/acrmp/foodcritic/pull/84)).
    Thanks @fnichol.
  - Remove unnecessary whitespace from rake task output
    ([related issue](https://github.com/acrmp/foodcritic/pull/78)).
    Thanks @ketan.
  - Removed [FC001: Use strings in preference to symbols to access node attributes](http://acrmp.github.com/foodcritic/#FC001)
    ([related issue](https://github.com/acrmp/foodcritic/issues/86)).
    Thanks @jtimberman.
  - [FC003: Check whether you are running with chef server before using server-specific features](http://acrmp.github.com/foodcritic/#FC003)
    updated to also match `unless`
    ([related issue](https://github.com/acrmp/foodcritic/issues/58)).
    Thanks @cap10morgan.
  - Decode numeric attributes.
    This could cause [FC005: Avoid repetition of resource declarations](http://acrmp.github.com/foodcritic/#FC005)
    to warn incorrectly
    ([related issue](https://github.com/acrmp/foodcritic/issues/79)).
    Thanks @masterkorp.
  - Recognise attributes correctly within a block.
    This could cause [FC005: Avoid repetition of resource declarations](http://acrmp.github.com/foodcritic/#FC005)
    to warn incorrectly
    ([related issue](https://github.com/acrmp/foodcritic/issues/76)).
    Thanks @masterkorp.
  - [FC009: Resource attribute not recognised](http://acrmp.github.com/foodcritic/#FC009)
    would warn incorrectly on methods used within a resource block
    ([related issue](https://github.com/acrmp/foodcritic/issues/85)).
    Thanks @arangamani.
  - [FC019: Access node attributes in a consistent manner](http://acrmp.github.com/foodcritic/#FC019)
    would warn incorrectly when referencing node attributes from a user-created
    hash.
    ([related issue](https://github.com/acrmp/foodcritic/issues/54)).
    Thanks @schubert.
  - [FC033: Missing Template](http://acrmp.github.com/foodcritic/#FC033)
    would warn incorrectly when using templates from another cookbook
    ([related issue](https://github.com/acrmp/foodcritic/issues/74)).
    Thanks @woohgit.

## 1.6.1 (31st August, 2012)

Bugfixes:

  - [FC030: Cookbook contains debugger breakpoints](http://acrmp.github.com/foodcritic/#FC030)
    could prevent other rules from processing depending on the tags passed.
  - [FC037: Invalid notification action](http://acrmp.github.com/foodcritic/#FC037)
    would incorrectly warn against `subscribes` notifications
    ([related issue](https://github.com/acrmp/foodcritic/issues/65)).
    Thanks @jtimberman.

## 1.6.0 (28th August, 2012)

Bugfixes:

  - Removed FC035: Template uses node attribute directly. For a discussion of
    the reasons for removal see the
    [related issue](https://github.com/acrmp/foodcritic/issues/60).

## 1.5.1 (21st August, 2012)

Bugfixes:

  - Remove pry-doc dependency to resolve pry version conflict.

## 1.5.0 (21st August, 2012)

Features:

  - [FC033: Missing template](http://acrmp.github.com/foodcritic/#FC033) rule
    added.
  - [FC034: Unused template variables](http://acrmp.github.com/foodcritic/#FC034)
    rule added
    ([related issue](https://github.com/acrmp/foodcritic/issues/36)).
  - [FC035: Template uses node attribute directly](http://acrmp.github.com/foodcritic/#FC035)
    rule added. This is a style rule that may prove controversial.
  - [FC037: Invalid notification action](http://acrmp.github.com/foodcritic/#FC037)
    rule added.
  - The `#read_ast` API method now supports Erb templates.
  - API method `#resource_action?` added.
  - DSL extended to include `library`, `metadata` and `template`.

Bugfixes:

  - [FC020: Conditional execution string attribute looks like Ruby](http://acrmp.github.com/foodcritic/#FC033)
    rule has been removed as unreliable.
  - The `#attribute_access` API method now correctly allows a type of `:any`.
  - The `#notifications` API method now supports notifications enclosed in braces
    ([related issue](https://github.com/etsy/foodcritic-rules/issues/3)).
  - Ensure command-line help is shown when an invalid option is passed. Thanks
    to @juanje for finding and fixing this issue.

## 1.4.0 (15th June, 2012)

Features:

  - [FC027: Resource sets internal attribute](http://acrmp.github.com/foodcritic/#FC027)
    rule added.
    Thanks @macros.
  - [FC028: Incorrect #platform? usage](http://acrmp.github.com/foodcritic/#FC028)
    rule added.
  - [FC029: No leading cookbook name in recipe metadata](http://acrmp.github.com/foodcritic/#FC029)
    rule added.
  - [FC030: Cookbook contains debugger breakpoints](http://acrmp.github.com/foodcritic/#FC030)
    rule added
    ([related issue](https://github.com/acrmp/foodcritic/issues/36)).
    Thanks @bryanwb.
  - [FC031: Cookbook without metadata file](http://acrmp.github.com/foodcritic/#FC031)
    rule added
    ([related issue](https://github.com/acrmp/foodcritic/issues/43)).
    Thanks to @juanje for proposing and implementing this rule.
  - [FC032: Invalid notification timing](http://acrmp.github.com/foodcritic/#FC032)
    rule added.
  - Added the [notifications](http://acrmp.github.com/foodcritic/#notifications)
    API method to provide more convenient access to resource notifications
    ([related issue](https://github.com/acrmp/foodcritic/issues/31)).

Bugfixes:

  - [FC003: Check whether you are running with chef server before using server-specific features](http://acrmp.github.com/foodcritic/#FC003)
    would warn if solo was checked for with `Chef::Config.solo`
    ([related issue](https://github.com/acrmp/foodcritic/issues/26)).
    Thanks to @miketheman for identifying and fixing this issue.
  - [FC007: Ensure recipe dependencies are reflected in cookbook metadata](http://acrmp.github.com/foodcritic/#FC007)
    would incorrectly warn if the cookbook name specified for `include_recipe`
    was dynamic
    ([related issue](https://github.com/acrmp/foodcritic/issues/44)).
    Thanks @markjreed.
  - [FC019: Access node attributes in a consistent manner](http://acrmp.github.com/foodcritic/#FC019)
    has been modified to no longer warn if the method called on node is called
    explicitly with brackets
    ([related issue](https://github.com/acrmp/foodcritic/issues/22)).
    Thanks @jaymzh.
  - The [resource_attributes](http://acrmp.github.com/foodcritic/#resource_attributes)
    API method has been updated to return boolean values correctly.

## 1.3.1 (9th June, 2012)

Bugfixes:

  - Changes made to support multiple cookbook paths in 1.3.0 broke
    compatibility with earlier versions of the linting API. This release
    restores compatibility with third party code that uses the linter
    `#cookbook_path` or `#valid_path?` methods.
  - The Nokogiri dependency constraint has been locked to 1.5.0 again as
    Nokogiri 1.5.3 also appears to segfault in certain circumstances.

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
