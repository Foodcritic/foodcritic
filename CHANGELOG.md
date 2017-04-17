# Foodcritic Changelog:

## [10.4.0](https://github.com/acrmp/foodcritic/tree/v10.4.1) (2017-04-17)

[Full Changelog](https://github.com/acrmp/foodcritic/compare/v10.4.0...v10.4.1)

**Implemented enhancements:**

- Removed the development dependency on github_changelog_generator

**Fixed bugs:**

- Fixed running cucumber tests using the cucumber CLI command
- Fixed FC016 incorrectly firing on custom resources that have no properties. FC016 will now skip over resources that have any actions as those are custom resources and custom resources don't need to declare a default_action.
- Added the missing chef13 tag to FC018
- Updated FC028 to detect both `node.platform_family?` in addition to the existing `node.platform?` usage. This rule has also been renamed and tags updated since the use of `node.platform?` is a style issue and not a correctness issue. Both `node.platform?` and `platform?` are acceptable in cookbooks.
- Fixed FC071 to not alert for cookbooks where the license is 'all rights reserved' in addition to the existing allowed 'All Rights Reserved' string
- Fixed FC071 to detect the LICENSE file if foodcritic is not running in the root of the cookbook
- Fixed FC070 to not alert when platform supports is defined through an array of platforms

## [10.4.0](https://github.com/acrmp/foodcritic/tree/v10.4.0) (2017-04-13)

[Full Changelog](https://github.com/acrmp/foodcritic/compare/v10.3.1...v10.4.0)

**Implemented enhancements:**

- Added FC076 to alert when the deprecated `conflicts` metadata is used
- Added FC077 to alert when the deprecated `replaces` metadata is used
- Added FC076 to alert when a non-OSI-approved license is used in metadata. You can disable this rule turning off the new `opensource` tag. For example: `foodcritic -t ~opensource .`

**Fixed bugs:**

- Regression tests now ignore .foodcritic files so we see all possible failures
- FC053 / FC052 updated to properly refer the metadata as deprecated and not unimplemented
- FC071 no longer alerts when cookbooks are licensed as "All Rights Reserved"

## [10.3.1](https://github.com/acrmp/foodcritic/tree/v10.3.1) (2017-04-10)

[Full Changelog](https://github.com/acrmp/foodcritic/compare/v10.3.0...v10.3.1)

**Implemented enhancements:**

- Added Chef 13.0.113 metadata, but retained 12.19.36 as the default

**Fixed bugs:**

- Resolved a regression when running Foodcritic as a Rake task

## [10.3.0](https://github.com/acrmp/foodcritic/tree/v10.3.0) (2017-04-10)

[Full Changelog](https://github.com/acrmp/foodcritic/compare/v10.2.2...v10.3.0)

**Implemented enhancements:**

- Added `FC069` to ensure standardized licenses are defined in metadata
- Added `FC070` to detect invalid platform supports in metadata
- Added `FC071` to ensure a LICENSE file is included with the cookbook
- Added `FC072` to detect attributes defined in metadata
- Added `FC073` to detect root alias collisions with non-root alias files
- Added `FC074` to detect setting the default_action in a LWRP without using the default_action DSL
- Added `FC075` to detect node.save usage
- Updated `FC008` to fail if the ChefDK generated boilerplate is included
- Updated `FC024` to not recommend adding amazon as an equivalent platform to Redhat as Amazon is its own platform family in Chef 13
- Updated `FC045` to no longer fail if metadata.rb cannot be found
- Added support for the Chef 13 root alias cookbook structure changes defined in <https://github.com/chef/chef-rfc/blob/master/rfc033-root-aliases.md>
- Testing has been completed reworked to simplify testing and allow for far more robust functional tests. Minitest unit tests have been converted to rspec and a new functional testing framework has been added utilizing rspec. Tests for a large number of the existing rules have been converted to this new framework. The new testing framework allows for simple all-in-one tests that are easier to read and much simpler to write. Additionally the regression tests have been reworked, and are now enabled in Travis CI, which will require regeneration of the expected output if new tests are added using `rake regen_regression`. See the readme for additional details on running tests.

## [10.2.2](https://github.com/acrmp/foodcritic/tree/v10.2.2) (2017-03-31)

[Full Changelog](https://github.com/acrmp/foodcritic/compare/v10.2.1...v10.2.2)

**Implemented enhancements:**

- Align rake setup better with CLI options to resolve bugs with tags in Rake [#533](https://github.com/acrmp/foodcritic/pull/533) ([tas50](https://github.com/tas50))

## [v10.2.1](https://github.com/acrmp/foodcritic/tree/v10.2.1) (2017-03-31)

[Full Changelog](https://github.com/acrmp/foodcritic/compare/v10.2.0...v10.2.1)

**Implemented enhancements:**

- Add supermarket tag to FC067 and FC068 [#532](https://github.com/acrmp/foodcritic/pull/532) ([tas50](https://github.com/tas50))

## [v10.2.0](https://github.com/acrmp/foodcritic/tree/v10.2.0) (2017-03-30)

[Full Changelog](https://github.com/acrmp/foodcritic/compare/v10.1.1...v10.2.0)

**Implemented enhancements:**

- Add FC066/FC067/FC068 to check metadata chef_version, license, and supports [#528](https://github.com/acrmp/foodcritic/pull/528) ([tas50](https://github.com/tas50))

**Fixed bugs:**

- Don't trigger FC007 on a shorthand recipe includes [#526](https://github.com/acrmp/foodcritic/pull/526) ([tas50](https://github.com/tas50))
- Fix already initialized constant warning with `--search-gems` [#529](https://github.com/acrmp/foodcritic/pull/529) ([nvwls](https://github.com/nvwls))

## [v10.1.1](https://github.com/acrmp/foodcritic/tree/v10.1.1) (2017-03-29)

[Full Changelog](https://github.com/acrmp/foodcritic/compare/v10.1.0...v10.1.1)

**Fixed bugs:**

- Fix FC016 triggering on custom resources [#525](https://github.com/acrmp/foodcritic/pull/525) ([tas50](https://github.com/tas50))

## [v10.1.0](https://github.com/acrmp/foodcritic/tree/v10.1.0) (2017-03-29)

[Full Changelog](https://github.com/acrmp/foodcritic/compare/v10.0.0...v10.1.0)

**Implemented enhancements:**

- Remove FC023 which is no longer considered best practice [#523](https://github.com/acrmp/foodcritic/pull/523) ([tas50](https://github.com/tas50))
- Add basic testing of the metadata_field api [#522](https://github.com/acrmp/foodcritic/pull/522) ([tas50](https://github.com/tas50))
- Add a more robust cookbook_base_path helper to the API [#520](https://github.com/acrmp/foodcritic/pull/520) ([tas50](https://github.com/tas50))
- Update various tags to better align the rules with the tag categories [#517](https://github.com/acrmp/foodcritic/pull/517) ([tas50](https://github.com/tas50))

## [v10.0.0](https://github.com/acrmp/foodcritic/tree/v10.0.0) (2017-03-14)

[Full Changelog](https://github.com/acrmp/foodcritic/compare/v9.0.0...v10.0.0)

**Implemented enhancements:**

- Add 12.19 metadata as default and remove 12.0 - 12.5.1 [#516](https://github.com/acrmp/foodcritic/pull/516) ([tas50](https://github.com/tas50))
- Remove FC003 from Foodcritic [#512](https://github.com/acrmp/foodcritic/pull/512) ([tas50](https://github.com/tas50))

## [v9.0.0](https://github.com/acrmp/foodcritic/tree/v9.0.0) (2017-01-31)

[Full Changelog](https://github.com/acrmp/foodcritic/compare/v8.2.0...v9.0.0)

**Implemented enhancements:**

- Add 12.18.31 metadata and make it the default [#508](https://github.com/acrmp/foodcritic/pull/508) ([tas50](https://github.com/tas50))
- Test on Ruby 2.4 and fix failing tests [#507](https://github.com/acrmp/foodcritic/pull/507) ([tas50](https://github.com/tas50))
- Support Chef RFC 17 compliant templates [#485](https://github.com/acrmp/foodcritic/pull/485) ([hagihala](https://github.com/hagihala))
- More sane default CLI values [#462](https://github.com/acrmp/foodcritic/pull/462) ([tas50](https://github.com/tas50))

## [v8.2.0](https://github.com/acrmp/foodcritic/tree/v8.2.0) (2017-01-09)

[Full Changelog](https://github.com/acrmp/foodcritic/compare/v8.1.0...v8.2.0)

**Implemented enhancements:**

- Add 12.17.44 metadata (and make it the default) [#505](https://github.com/acrmp/foodcritic/pull/505) ([tas50](https://github.com/tas50))
- Add 12.16.42 metadata and make it the default [#497](https://github.com/acrmp/foodcritic/pull/497) ([tas50](https://github.com/tas50))

## [v8.1.0](https://github.com/acrmp/foodcritic/tree/v8.1.0) (2016-10-20)

[Full Changelog](https://github.com/acrmp/foodcritic/compare/v8.0.0...v8.1.0)

**Implemented enhancements:**

- Add Chef client 12.15.19 metadata [#493](https://github.com/acrmp/foodcritic/pull/493) ([tas50](https://github.com/tas50))
- Clarify exclude path instructions in the CLI help [#489](https://github.com/acrmp/foodcritic/pull/489) ([unixorn](https://github.com/unixorn))

## [v8.0.0](https://github.com/acrmp/foodcritic/tree/v8.0.0) (2016-09-23)

[Full Changelog](https://github.com/acrmp/foodcritic/compare/v7.1.0...v8.0.0)

**Implemented enhancements:**

- Require Ruby 2.2.2 [#487](https://github.com/acrmp/foodcritic/pull/487) ([tas50](https://github.com/tas50))
- Add 12.14.89 metadata and make it the default [#486](https://github.com/acrmp/foodcritic/pull/486) ([tas50](https://github.com/tas50))
- Remove Chef 11 metadata and rule support [#481](https://github.com/acrmp/foodcritic/pull/481) ([tas50](https://github.com/tas50))

## [v7.1.0](https://github.com/acrmp/foodcritic/tree/v7.1.0) (2016-08-17)

[Full Changelog](https://github.com/acrmp/foodcritic/compare/v7.0.1...v7.1.0)

**Implemented enhancements:**

- Add Chef 12.13.37 metadata and make it the default [#479](https://github.com/acrmp/foodcritic/pull/479) ([tas50](https://github.com/tas50))
- Add 12.12.13 metadata and fix metadata generation [#472](https://github.com/acrmp/foodcritic/pull/472) ([tas50](https://github.com/tas50))

**Fixed bugs:**

- Add missing assigment attributes [#478](https://github.com/acrmp/foodcritic/pull/478) ([ofir-petrushka](https://github.com/ofir-petrushka))

## [v7.0.1](https://github.com/acrmp/foodcritic/tree/v7.0.1) (2016-07-06)

[Full Changelog](https://github.com/acrmp/foodcritic/compare/v7.0.0...v7.0.1)

**Implemented enhancements:**

- Readme improvements [#468](https://github.com/acrmp/foodcritic/pull/468) ([tas50](https://github.com/tas50))

## [v7.0.0](https://github.com/acrmp/foodcritic/tree/v7.0.0) (2016-07-05)

[Full Changelog](https://github.com/acrmp/foodcritic/compare/v6.3.0...v7.0.0)

**Implemented enhancements:**

- Remove support for Ruby 2.0 [#465](https://github.com/acrmp/foodcritic/pull/465) ([tas50](https://github.com/tas50))
- Remove chef version support for Chef 0.7, 0.8, 0.9, and 0.10 [#464](https://github.com/acrmp/foodcritic/pull/464) ([tas50](https://github.com/tas50))
- Add chef 12.11.18 metadata and make it the default [#461](https://github.com/acrmp/foodcritic/pull/461) ([tas50](https://github.com/tas50))
- FC032 allow the new :before timing on resource notifications in Chef >= 12.6.0 [#441](https://github.com/acrmp/foodcritic/pull/441) ([gnjack](https://github.com/gnjack))
- New cookbook_maintainer api methods [#248](https://github.com/acrmp/foodcritic/pull/248) ([miguelcnf](https://github.com/miguelcnf))

## [v6.3.0](https://github.com/acrmp/foodcritic/tree/v6.3.0) (2016-05-16)

[Full Changelog](https://github.com/acrmp/foodcritic/compare/v6.2.0...v6.3.0)

**Implemented enhancements:**

- Add Chef 12.10.24 metadata and release 6.3.0 [#456](https://github.com/acrmp/foodcritic/pull/456) ([tas50](https://github.com/tas50))

## [v6.2.0](https://github.com/acrmp/foodcritic/tree/v6.2.0) (2016-04-26)

[Full Changelog](https://github.com/acrmp/foodcritic/compare/v6.1.1...v6.2.0)

**Implemented enhancements:**

- Add 12.9.38 metadata and make it the default chef version [#452](https://github.com/acrmp/foodcritic/pull/452) ([tas50](https://github.com/tas50))

## [v6.1.1](https://github.com/acrmp/foodcritic/tree/v6.1.1) (2016-04-08)

[Full Changelog](https://github.com/acrmp/foodcritic/compare/v6.1.0...v6.1.1)

**Implemented enhancements:**

- Use latest gherkin for faster installs [#447](https://github.com/acrmp/foodcritic/pull/447) ([jkeiser](https://github.com/jkeiser))

## [v6.1.0](https://github.com/acrmp/foodcritic/tree/v6.1.0) (2016-04-06)

[Full Changelog](https://github.com/acrmp/foodcritic/compare/v6.0.1...v6.1.0)

**Implemented enhancements:**

- Don't require cucumber and rubocop to run rake [#444](https://github.com/acrmp/foodcritic/pull/444) ([jkeiser](https://github.com/jkeiser))
- Add 12.8.1 metadata + update metadata process [#438](https://github.com/acrmp/foodcritic/pull/438) ([tas50](https://github.com/tas50))
- Add metadata for Chef 12.7.2 and update instructions [#427](https://github.com/acrmp/foodcritic/pull/427) ([tas50](https://github.com/tas50))

**Fixed bugs:**

- Rake.last_comment was depreciated in Rake11\. [#434](https://github.com/acrmp/foodcritic/pull/434) ([gkuchta](https://github.com/gkuchta))

## [v6.0.1](https://github.com/acrmp/foodcritic/tree/v6.0.1) (2016-02-22)

[Full Changelog](https://github.com/acrmp/foodcritic/compare/v6.0.0...v6.0.1)

**Implemented enhancements:**

- Check for URLs that are helpful to the Supermarket [#421](https://github.com/acrmp/foodcritic/pull/421) ([nathenharvey](https://github.com/nathenharvey))

**Fixed bugs:**

- Fix FC058 false positives [#423](https://github.com/acrmp/foodcritic/pull/423) ([jaym](https://github.com/jaym))

## [v6.0.0](https://github.com/acrmp/foodcritic/tree/v6.0.0) (2016-01-14)

[Full Changelog](https://github.com/acrmp/foodcritic/compare/v5.0.0...v6.0.0)

**Implemented enhancements:**

- Cookbook version is specified in metadata [#347](https://github.com/acrmp/foodcritic/issues/347)
- FC035 - Templates, Style [#62](https://github.com/acrmp/foodcritic/issues/62)
- Add Chef 12.6.0 metadata [#417](https://github.com/acrmp/foodcritic/pull/417) ([tas50](https://github.com/tas50))
- New Rule 61 - valid cookbook version [#405](https://github.com/acrmp/foodcritic/pull/405) ([lamont-granquist](https://github.com/lamont-granquist))
- Require Oracle as a RHEL equiv [#404](https://github.com/acrmp/foodcritic/pull/404) ([tas50](https://github.com/tas50))
- Suggest updating from definitions to custom resources [#403](https://github.com/acrmp/foodcritic/pull/403) ([tas50](https://github.com/tas50))
- add checks for correct use of use_inline_resources [#402](https://github.com/acrmp/foodcritic/pull/402) ([lamont-granquist](https://github.com/lamont-granquist))
- Add new tags for rules [#401](https://github.com/acrmp/foodcritic/pull/401) ([tas50](https://github.com/tas50))
- Rename FC045 since Chef 12 requires name metadata [#399](https://github.com/acrmp/foodcritic/pull/399) ([tas50](https://github.com/tas50))
- Add Chef 12.5.1 metadata [#397](https://github.com/acrmp/foodcritic/pull/397) ([tas50](https://github.com/tas50))
- Add self-dependency warning [#328](https://github.com/acrmp/foodcritic/pull/328) ([lamont-granquist](https://github.com/lamont-granquist))

**Fixed bugs:**

- Time to cut a release? [#344](https://github.com/acrmp/foodcritic/issues/344)
- FC048: Warn within a provider block, refs #365 [#413](https://github.com/acrmp/foodcritic/pull/413) ([acrmp](https://github.com/acrmp))
- use_inline_resources checks apply to Chef 11+ [#410](https://github.com/acrmp/foodcritic/pull/410) ([tas50](https://github.com/tas50))
- fix for edge condition with 061 [#408](https://github.com/acrmp/foodcritic/pull/408) ([lamont-granquist](https://github.com/lamont-granquist))
- Rake options override default options [#382](https://github.com/acrmp/foodcritic/pull/382) ([pkang](https://github.com/pkang))

**Closed issues:**

- Chef Docs vs Foodcritic 4.x [#354](https://github.com/acrmp/foodcritic/issues/354)
- Github pages have drifted from foodcritic.io [#332](https://github.com/acrmp/foodcritic/issues/332)
- FC001 is re-enabled thus <http://www.foodcritic.io/> is out-of-date [#330](https://github.com/acrmp/foodcritic/issues/330)

## [v5.0.0](https://github.com/acrmp/foodcritic/tree/v5.0.0) (2015-09-17)

[Full Changelog](https://github.com/acrmp/foodcritic/compare/v4.0.0...v5.0.0)

**Implemented enhancements:**

- Support for a magic comment to temporarily disable a rule [#259](https://github.com/acrmp/foodcritic/issues/259)
- FC007 false positive on depending on the cookbook currently being parsed [#242](https://github.com/acrmp/foodcritic/issues/242)
- Create a rule for "execute resource used to install packages" [#180](https://github.com/acrmp/foodcritic/issues/180)
- New Rule Proposal: uid/gid should be integer [#53](https://github.com/acrmp/foodcritic/issues/53)
- merge default options before check instead of during intialization [#321](https://github.com/acrmp/foodcritic/pull/321) ([ranjib](https://github.com/ranjib))

**Fixed bugs:**

- Fix FC031 and FC045 and metadata.rb vs metadata.json issues [#369](https://github.com/acrmp/foodcritic/issues/369)
- FC007 false positive on depending on the cookbook currently being parsed [#242](https://github.com/acrmp/foodcritic/issues/242)
- FC010 Test failures due to missing search support [#199](https://github.com/acrmp/foodcritic/issues/199)
- 'lazy' causes false-positive in FC009 - on previous line [#189](https://github.com/acrmp/foodcritic/issues/189)
- FC051 tries to validate temp files of the editors [#172](https://github.com/acrmp/foodcritic/issues/172)

## [v4.0.0](https://github.com/acrmp/foodcritic/tree/v4.0.0) (2014-06-11)

[Full Changelog](https://github.com/acrmp/foodcritic/compare/v3.0.3...v4.0.0)

## [v3.0.3](https://github.com/acrmp/foodcritic/tree/v3.0.3) (2013-10-13)

[Full Changelog](https://github.com/acrmp/foodcritic/compare/v3.0.2...v3.0.3)

## [v3.0.2](https://github.com/acrmp/foodcritic/tree/v3.0.2) (2013-10-05)

[Full Changelog](https://github.com/acrmp/foodcritic/compare/v3.0.1...v3.0.2)

## [v3.0.1](https://github.com/acrmp/foodcritic/tree/v3.0.1) (2013-09-25)

[Full Changelog](https://github.com/acrmp/foodcritic/compare/v3.0.0...v3.0.1)

**Implemented enhancements:**

- Roles rules [#19](https://github.com/acrmp/foodcritic/issues/19)

## [v3.0.0](https://github.com/acrmp/foodcritic/tree/v3.0.0) (2013-09-14)

[Full Changelog](https://github.com/acrmp/foodcritic/compare/v2.2.0...v3.0.0)

**Implemented enhancements:**

- Provide a comprehensive list of `tags` somewhere on the docs [#63](https://github.com/acrmp/foodcritic/issues/63)

**Fixed bugs:**

- FC001, FC019 shouldn't match on node.run_state [#66](https://github.com/acrmp/foodcritic/issues/66)

## [v2.2.0](https://github.com/acrmp/foodcritic/tree/v2.2.0) (2013-07-10)

[Full Changelog](https://github.com/acrmp/foodcritic/compare/v2.1.0...v2.2.0)

## [v2.1.0](https://github.com/acrmp/foodcritic/tree/v2.1.0) (2013-04-16)

[Full Changelog](https://github.com/acrmp/foodcritic/compare/v2.0.1...v2.1.0)

**Implemented enhancements:**

- New Rule Proposal: ||= considered harmful with attributes [#52](https://github.com/acrmp/foodcritic/issues/52)
- Would like to be able to exempt rules in cookbooks [#10](https://github.com/acrmp/foodcritic/issues/10)

## [v2.0.1](https://github.com/acrmp/foodcritic/tree/v2.0.1) (2013-03-31)

[Full Changelog](https://github.com/acrmp/foodcritic/compare/v2.0.0...v2.0.1)

## [v2.0.0](https://github.com/acrmp/foodcritic/tree/v2.0.0) (2013-03-24)

[Full Changelog](https://github.com/acrmp/foodcritic/compare/v1.7.0...v2.0.0)

**Implemented enhancements:**

- New Rule: Check for existence of 'name' in metadata.rb [#64](https://github.com/acrmp/foodcritic/issues/64)
- New Rule: action ":none" vs ":nothing" [#61](https://github.com/acrmp/foodcritic/issues/61)

**Fixed bugs:**

- Incorrectly decoding attributes within a block [#76](https://github.com/acrmp/foodcritic/issues/76)
- FC003 doesn't match unless statements [#58](https://github.com/acrmp/foodcritic/issues/58)
- FC019 triggered on internal recipe hash key as symbol instead of node [#54](https://github.com/acrmp/foodcritic/issues/54)

## [v1.7.0](https://github.com/acrmp/foodcritic/tree/v1.7.0) (2012-12-27)

[Full Changelog](https://github.com/acrmp/foodcritic/compare/v1.6.1...v1.7.0)

**Fixed bugs:**

- FC037 false positive for subscribes [#65](https://github.com/acrmp/foodcritic/issues/65)
- Foodcritic not being fully deterministic. [#55](https://github.com/acrmp/foodcritic/issues/55)

## [v1.6.1](https://github.com/acrmp/foodcritic/tree/v1.6.1) (2012-08-30)

[Full Changelog](https://github.com/acrmp/foodcritic/compare/v1.6.0...v1.6.1)

## [v1.6.0](https://github.com/acrmp/foodcritic/tree/v1.6.0) (2012-08-28)

[Full Changelog](https://github.com/acrmp/foodcritic/compare/v1.5.0...v1.6.0)

**Implemented enhancements:**

- Thoughts on more style-y lint checks [#15](https://github.com/acrmp/foodcritic/issues/15)

**Fixed bugs:**

- FC020 triggered on non-ruby shell command [#30](https://github.com/acrmp/foodcritic/issues/30)
- Incorrect FC019 alarms [#22](https://github.com/acrmp/foodcritic/issues/22)

## [v1.5.0](https://github.com/acrmp/foodcritic/tree/v1.5.0) (2012-08-20)

[Full Changelog](https://github.com/acrmp/foodcritic/compare/v1.5.1...v1.5.0)

## [v1.5.1](https://github.com/acrmp/foodcritic/tree/v1.5.1) (2012-08-20)

[Full Changelog](https://github.com/acrmp/foodcritic/compare/v1.4.0...v1.5.1)

**Fixed bugs:**

- FC007 should not be triggered by include_recipe "#{cookbook_name}::blah" [#44](https://github.com/acrmp/foodcritic/issues/44)
- FC022 block name check appears to be too simplistic [#29](https://github.com/acrmp/foodcritic/issues/29)

## [v1.4.0](https://github.com/acrmp/foodcritic/tree/v1.4.0) (2012-06-15)

[Full Changelog](https://github.com/acrmp/foodcritic/compare/v1.3.1...v1.4.0)

## [v1.3.1](https://github.com/acrmp/foodcritic/tree/v1.3.1) (2012-06-09)

[Full Changelog](https://github.com/acrmp/foodcritic/compare/v1.3.0...v1.3.1)

**Implemented enhancements:**

- catch pry breakpoints [#36](https://github.com/acrmp/foodcritic/issues/36)

**Fixed bugs:**

- resource_attributes should show all of the relevant part of the AST [#31](https://github.com/acrmp/foodcritic/issues/31)
- FC003 is triggered, despite being handled [#26](https://github.com/acrmp/foodcritic/issues/26)

## [v1.3.0](https://github.com/acrmp/foodcritic/tree/v1.3.0) (2012-05-21)

[Full Changelog](https://github.com/acrmp/foodcritic/compare/v1.2.0...v1.3.0)

## [v1.2.0](https://github.com/acrmp/foodcritic/tree/v1.2.0) (2012-04-21)

[Full Changelog](https://github.com/acrmp/foodcritic/compare/v1.1.0...v1.2.0)

## [v1.1.0](https://github.com/acrmp/foodcritic/tree/v1.1.0) (2012-03-25)

[Full Changelog](https://github.com/acrmp/foodcritic/compare/v1.0.1...v1.1.0)

**Fixed bugs:**

- ruby segfault / foodcritic 1.0.0 / nokogiri 1.5.2 [#18](https://github.com/acrmp/foodcritic/issues/18)

## [v1.0.1](https://github.com/acrmp/foodcritic/tree/v1.0.1) (2012-03-15)

[Full Changelog](https://github.com/acrmp/foodcritic/compare/v1.0.0...v1.0.1)

**Implemented enhancements:**

- rules in code? [#8](https://github.com/acrmp/foodcritic/issues/8)

## [v1.0.0](https://github.com/acrmp/foodcritic/tree/v1.0.0) (2012-03-04)

[Full Changelog](https://github.com/acrmp/foodcritic/compare/v0.11.1...v1.0.0)

**Implemented enhancements:**

- Foodcritic doesn't have a -v [#16](https://github.com/acrmp/foodcritic/issues/16)

**Fixed bugs:**

- FC003: Recognise updated chef-solo-search [#17](https://github.com/acrmp/foodcritic/issues/17)
- foodcritic v10 and v11 have conflicting yajl-ruby dependencies with chef [#14](https://github.com/acrmp/foodcritic/issues/14)

## [v0.11.1](https://github.com/acrmp/foodcritic/tree/v0.11.1) (2012-02-29)

[Full Changelog](https://github.com/acrmp/foodcritic/compare/v0.11.0...v0.11.1)

**Implemented enhancements:**

- Want "all" arg to '-f' option. [#11](https://github.com/acrmp/foodcritic/issues/11)

**Fixed bugs:**

- Epic fail fail? [#13](https://github.com/acrmp/foodcritic/issues/13)

## [v0.11.0](https://github.com/acrmp/foodcritic/tree/v0.11.0) (2012-02-22)

[Full Changelog](https://github.com/acrmp/foodcritic/compare/v0.10.0...v0.11.0)

**Fixed bugs:**

- Numeric value for mode should be 5 digits (CHEF-174) [#9](https://github.com/acrmp/foodcritic/pull/9) ([aia](https://github.com/aia))

## [v0.10.0](https://github.com/acrmp/foodcritic/tree/v0.10.0) (2012-02-20)

[Full Changelog](https://github.com/acrmp/foodcritic/compare/v0.9.0...v0.10.0)

## [v0.9.0](https://github.com/acrmp/foodcritic/tree/v0.9.0) (2012-01-26)

[Full Changelog](https://github.com/acrmp/foodcritic/compare/v0.8.1...v0.9.0)

## [v0.8.1](https://github.com/acrmp/foodcritic/tree/v0.8.1) (2012-01-20)

[Full Changelog](https://github.com/acrmp/foodcritic/compare/v0.8.0...v0.8.1)

## [v0.8.0](https://github.com/acrmp/foodcritic/tree/v0.8.0) (2012-01-19)

[Full Changelog](https://github.com/acrmp/foodcritic/compare/v0.7.0...v0.8.0)

**Fixed bugs:**

- Don't raise FC003 warning if chef-solo-search is installed [#7](https://github.com/acrmp/foodcritic/issues/7)

## [v0.7.0](https://github.com/acrmp/foodcritic/tree/v0.7.0) (2011-12-31)

[Full Changelog](https://github.com/acrmp/foodcritic/compare/v0.6.0...v0.7.0)

## [v0.6.0](https://github.com/acrmp/foodcritic/tree/v0.6.0) (2011-12-18)

[Full Changelog](https://github.com/acrmp/foodcritic/compare/v0.5.2...v0.6.0)

**Fixed bugs:**

- Bundler fails to resolve JSON version [#6](https://github.com/acrmp/foodcritic/issues/6)

## [v0.5.2](https://github.com/acrmp/foodcritic/tree/v0.5.2) (2011-12-15)

[Full Changelog](https://github.com/acrmp/foodcritic/compare/v0.5.1...v0.5.2)

## [v0.5.1](https://github.com/acrmp/foodcritic/tree/v0.5.1) (2011-12-14)

[Full Changelog](https://github.com/acrmp/foodcritic/compare/v0.5.0...v0.5.1)

## [v0.5.0](https://github.com/acrmp/foodcritic/tree/v0.5.0) (2011-12-13)

[Full Changelog](https://github.com/acrmp/foodcritic/compare/v0.4.0...v0.5.0)

## [v0.4.0](https://github.com/acrmp/foodcritic/tree/v0.4.0) (2011-12-10)

[Full Changelog](https://github.com/acrmp/foodcritic/compare/v0.3.0...v0.4.0)

## [v0.3.0](https://github.com/acrmp/foodcritic/tree/v0.3.0) (2011-12-04)

[Full Changelog](https://github.com/acrmp/foodcritic/compare/v0.2.0...v0.3.0)

## [v0.2.0](https://github.com/acrmp/foodcritic/tree/v0.2.0) (2011-12-01)

[Full Changelog](https://github.com/acrmp/foodcritic/compare/v0.1.0...v0.2.0)

## [v0.1.0](https://github.com/acrmp/foodcritic/tree/v0.1.0) (2011-11-30)

[Full Changelog](https://github.com/acrmp/foodcritic/compare/4257264aa0bf93e3d13851ac0343a6b25ca3d316...v0.1.0)

- _This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)_
