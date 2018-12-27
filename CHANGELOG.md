# Foodcritic Changelog:

## [15.1.0](https://github.com/Foodcritic/foodcritic/tree/v15.1.0) (2018-12-26)

- Stripped test files from the gem artifact to slim the install size
- Removed the legacy man page file that appears to be used
- Updated chef metadata to 14.8 which provides information on the actions / properties of windows_task

## [15.0.0](https://github.com/Foodcritic/foodcritic/tree/v15.0.0) (2018-12-03)

With this release of Foodcritic we are now shipping only metadata for the latest versions of each supported Chef version. Chef metadata files are getting increasingly large and this is increasing the size of Chef DK/Workstation significantly. This release ships with Chef 14.7 and 13.12 metadata and future releases will update the metadata versions without a major version bump as this should not be considered a breaking change.

## [14.3.0](https://github.com/Foodcritic/foodcritic/tree/v14.3.0) (2018-10-23)

- Added Chef 13.11.3 metadata
- Removed Chef 13.5, 13.6, 13.7 and 13.9 metadata
- Disabled FC121 for now. This rule was causing a lot of confusion and resulting in authors dropping support for Chef 13 prematurely. This rule we get enabled again when Chef 13 goes EOL this coming April

## [14.2.0](https://github.com/Foodcritic/foodcritic/tree/v14.2.0) (2018-09-30)

- Add Chef 14.5 metadata with 14.4 being the new default
- Removed Chef 13.4 metadata
- Pin cucumber-core to prevent pulling in new breaking changes

## [14.1.0](https://github.com/Foodcritic/foodcritic/tree/v14.1.0) (2018-08-30)

- Add Chef 14.3 and 14.4 metadata with 14.4 being the new default

## [14.0.0](https://github.com/Foodcritic/foodcritic/tree/v14.0.0) (2018-06-28)

- Removed Chef 13.0, 13.1, and 13.3 metadata.
- Added Chef 13.9, 14.1, and 14.2 metadata and made 14.2 the new default, which adds property checking for all new Chef 14 resources to Foodcritic.
- Renamed FC048 from "Prefer Mixlib::ShellOut" to "Prefer shell_out helper method to shelling out with Ruby" since Chef includes a helpful shell_out helper that is the preferred way to shell out in resources or libraries.
- Removed FC012, which looked for legacy README.rdoc files. These haven't existed since the very early days of Chef and our existing check for README.MD files will catch any cookbooks still missing the proper format.
- Added the opensource tag to FC071: Missing LICENSE file. This lets you easily skip this by excluding any rules tagged with opensource.
- Added a new rule FC121: Cookbook depends on cookbook made obsolete by Chef 14\. This rule detects cookbook which depend on build-essential, dmg, chef_handler, chef_hostname, mac_os_x, swap, or sysctl cookbooks. The resources from these cookbooks now ship in Chef 14 and depending on the cookbooks is no longer necessary. Note removing these dependencies does increase the minimum required chef-client for
- The non-existent resource UnresolvedSubscribes has been removed from the metadata files slimming Foodcritic's install size by 1500 lines.
- Updated the list of SPDX licenses in FC069 and FC078 to the current list.

## [13.1.1](https://github.com/Foodcritic/foodcritic/tree/v13.1.1) (2018-04-12)

- Fixed an error in the detection of attributes.rb files when using root alias functionality
- Updated rules that used the 'deprecation' tag to instead use the 'deprecated' tag. All rules for deprecated functionality now have the same catch all tag.

## [13.1.0](https://github.com/Foodcritic/foodcritic/tree/v13.1.0) (2018-04-12)

### Speed improvements

Foodcritic now caches some of the information on cookbooks it previously calculated repeatedly. This results in a 10X reduction in some disk reads and a 7% improvement in runtime overall.

### Rule file improvements

The fetching and parsing of Foodcritic rule files (.foodcritic files) has been improved. If a non-existent file is specified on the CLI we will now fail instead of silently continuing. Additionally, if the .foodcritic file exists, but cannot be read/parsed we will also fail instead of silently continuing.

### Improved file detection

Several deficiencies in how Foodcritic detected files within a cookbook have been resolved. If you use the Chef 13+ root alias files such as attributes.rb or recipe.rb these will now be detected. Additionally we will detect template files not in the default directory, or deeply nested in directories within the templates directory.

### New Rules

- `FC116` - Cookbook depends on the deprecated compat_resource cookbook
- `FC120` - Do not set the name property directly on a resource
- `FC122` - Use the build_essential resource instead of the recipe

## [13.0.1](https://github.com/Foodcritic/foodcritic/tree/v13.0.1) (2018-04-11)

- Properly discover templates not in templates/default/. Templates in the root of the templates directory would be skipped previously
- Force encoding to UTF8 to prevent errors when encoding isn't set on the host
- Alert with the filename when an improperly encoded file is encountered instead of silently failing
- Removed the chef13 tag from FC085

## [13.0.0](https://github.com/Foodcritic/foodcritic/tree/v13.0.0) (2018-03-07)

### Chef 12 Support

As Chef 12 goes end of life next month this release makes several changes assuming Chef 13+:

Support for Ruby 2.2 has been removed

Chef 12 metadata files have been removed.

A new rule FC113: Resource declares deprecated use_inline_resources, which suggests a coding standard that requires Chef 13+. This rule is being introduced as use_inline_resources will begin throwing deprecation warnings in later Chef 14 releases and will eventually be removed from Chef.

Removed FC017: LWRP does not notify when updated. This is no longer applicable with Chef 13+ since inline resources are always used and notifications in resources happen automatically.

If full Chef 12 support is necessary then Foodcritic 12.2.2 is probably the best release to stick with. Keep in mind that later Foodcritic releases include rules that aid in Chef upgrades so sticking with an older release is not advised. Instead you should disable individual rules or tags that don't apply to your organization.

### New/Removed Rules

- Added FC113: Resource declares deprecated use_inline_resources.
- Added FC115: Custom resource contains a name_property that is required
- Added FC117: Do not use kind_of in custom resource properties
- Added FC118: Resource property setting name_attribute vs. name_property
- Added FC119: windows_task :change action no longer exists in Chef 13
- Removed FC017: LWRP does not notify when updated.

### Other Changes

- Updated the notification_action API to detect actions that aren't symbols
- Expand FC037 to detect notifying with actions as strings
- Incompatibilities with Ruby 2.5 and FC025/FC026 have been resolved
- Added Chef 13.7.16 metadata
- The chef12 tag has been removed from FC064/FC065 has issue_url and source_url metadata aren't actually required by chef 12\. This makes it seem as though users need to add this metadata to migrate to Chef 12, which isn't the case.

## [12.3.0](https://github.com/Foodcritic/foodcritic/tree/v12.3.0) (2018-01-18)

**Implemented enhancements:**

- Removed FC017, FC057, and FC059 as use_inline_resources is the default in Chef 13 and no longer required
- Added FC110: Script resources should use 'code' property not 'command' property
- Added FC111: search using deprecated sort flag
- Added FC112 Resource using deprecated dsl_name method
- Added FC113 Resource declares deprecated use_inline_resources
- Added FC114 Cookbook uses legacy Ohai config syntax
- Extended the find_resources method to allow accepting an array of resource names not just a single resource name

## [12.2.2](https://github.com/Foodcritic/foodcritic/tree/v12.2.2) (2017-12-13)

**Fixed bugs:**

- Don't require a space before the # in an ignore comment.
- FC009 should not alert on a raise in a resource
- Catch systemd service starts in FC004 and resolve several false positives

## [12.2.1](https://github.com/Foodcritic/foodcritic/tree/v12.2.1) (2017-11-14)

**Fixed bugs:**

- Fixed FC104 alerting for any resource with a :create action instead of just ruby_block resources

## [12.2.0](https://github.com/Foodcritic/foodcritic/tree/v12.2.0) (2017-11-14)

**Implemented enhancements:**

- Added Chef 13.6 resource metadata
- Added FC103: Deprecated :uninstall action in chocolatey_package used
- Added FC104: Use the :run action in ruby_block instead of :create
- Added FC105: Deprecated erl_call resource used
- Added FC106: Use the plist_hash property in launchd instead of hash
- Added FC107: Resource uses epic_fail instead of ignore_failure
- Added FC108: Resource should not define a property named 'name'
- Added FC109: Use platform-specific package resources instead of provider property
- Updated FC085 to also alert on @new_resource.updated_by_last_action
- Refactored multiple rules to simplify which files they trigger on

**Fixed bugs:**

- Updated FC086 to only alert if someone is using DataBagItem/EncryptedDataBagItem to load a data bag

## [12.1.0](https://github.com/Foodcritic/foodcritic/tree/v12.1.0) (2017-10-31)

**Implemented enhancements:**

- Updated FC094 and FC095 tags from chef15 -> chef14 as the deprecation timeline has been changed
- Updated FC087 to check for all deprecated Chef::Platform methods
- Added FC101: Cookbook uses the deprecated deploy resource
- Added FC102: Cookbook uses the deprecated Chef::DSL::Recipe::FullDSL class

## [12.0.1](https://github.com/Foodcritic/foodcritic/tree/v12.0.1) (2017-10-19)

**Fixed bugs:**

- Fixed the tags for new rules to correctly specify the version of Chef where the breaking change will occur, not the version of Chef were the deprecation warning was introduced

## [12.0.0](https://github.com/Foodcritic/foodcritic/tree/v12.0.0) (2017-10-18)

**Implemented enhancements:**

- Added FC093 - Generated README text needs updating
- Added FC094 - Deprecated filesystem2 ohai plugin data used
- Added FC095 - Deprecated cloud_v2 ohai plugin data used
- Added FC096 - Deprecated libvirt virtualization ohai data used
- Added FC097 - Deprecated Chef::Mixin::LanguageIncludeAttribute class used
- Added FC098 - Deprecated Chef::Mixin::RecipeDefinitionDSLCore class used
- Added FC099 - Deprecated Chef::Mixin::LanguageIncludeRecipe class used
- Added FC100 - Deprecated Chef::Mixin::Language class used
- Removed metadata for Chef versions 12.10, 12.11, 12.13, 12.14
- Added metadata for Chef 12.21 and 13.5

## [11.4.0](https://github.com/Foodcritic/foodcritic/tree/v11.4.0) (2017-09-13)

**Implemented enhancements:**

- Added metadata for Chef 13.3.42 and 13.4.19 to include the latest new resources shipped in chef-client

## [11.3.1](https://github.com/Foodcritic/foodcritic/tree/v11.3.1) (2017-08-17)

**Fixed bugs:**

- Allow EncryptedDataBagItem.load_secret in FC086

## [11.3.0](https://github.com/Foodcritic/foodcritic/tree/v11.3.0) (2017-07-12)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/v11.2.0...v11.3.0)

**Implemented enhancements:**

- The yajl-ruby dependency has been replaced with ffi-yajl which is used by Chef and is already present in ChefDK. A single usage of Ruby's JSON parser has also been replaced with ffi-yajl as well.
- FC033 logic has been slightly simplified.

**Fixed bugs:**

- FC001 will no longer alert when a user references the run_state, which is correctly accessed as a symbol and not a string.

## [11.2.0](https://github.com/Foodcritic/foodcritic/tree/v11.2.0) (2017-06-12)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/v11.1.0...v11.2.0)

**Implemented enhancements:**

- Added metadata for Chef 13.1 and made this the default. This means that FC009 will now alert on cookbooks using code that has been removed in Chef 13.
- Added FC091: Use property not attribute in custom resources.
- Added FC092: Custom resources should not define actions.
- Removed metadata for Chef 12.6, 12.7, and 12.8\. This only impacts users specifically setting these metadata versions via the command line.
- Disabled the `opensource` tag by default to simply use of Foodcritic for non-community cookbook developers. At the time of writing this only includes `FC078`. To enable it again: `foodcritic -t any .`
- Added a Dockerfile for running Foodcritic in Docker.

## [11.1.0](https://github.com/Foodcritic/foodcritic/tree/v11.1.0) (2017-05-18)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/v11.0.0...v11.1.0)

**Implemented enhancements:**

- Added `FC086` - Use databag helper methods to load data bag items. Tags: style
- Added `FC087` - Library maps provider with deprecated Chef::Platform.set. Tags: chef13 deprecated
- Added `FC088` - Prefer Mixlib::Shellout over deprecated Chef::Mixin::Command. Tags: chef13 deprecated
- Added `FC089` - Prefer Mixlib::Shellout over deprecated Chef::ShellOut. Tags: chef13 deprecated
- Added a new `--rule-file` flag to specify the path to your .foodcritic file
- Added metadata for Chef 12.20.3 and made it the default
- Updated several rule names to be more clear that we're checking for deprecated functionality

## [11.0.0](https://github.com/Foodcritic/foodcritic/tree/v11.0.0) (2017-04-24)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/v10.4.1...v11.0.0)

**Implemented enhancements:**

- Added `FC079` to detect the usage of the easy_install_package resource which is deprecated in Chef 13\. Tags: deprecated, chef13.
- Added `FC080` to detect user resources that include the supports property, which is deprecated in Chef 13\. Tags: deprecated, chef13.
- Added `FC081` to detect a cookbook that depends on the partial_search cookbook as partial search functionality is built into Chef 12 and later. Tags: chef12.
- Added `FC082` to detect the usage of node.set and node.set_unless which will be removed in Chef 14\. Tags: deprecated, chef14.
- Added `FC083` to detect execute resources that include the path property, which is deprecated in Chef 12\. Tags: deprecated, chef12.
- Added `FC084` to detect usage of the deprecated Chef::REST class. Tags: deprecated, chef13.
- Added `FC085` to detect usage of new_resource.updated_by_last_action to converge resources. Tags: deprecated, chef13.
- Updated and refactored API methods `declared_dependencies`, `supported_platforms`, and `word_list_values`
- Deprecated API methods `checks_for_chef_solo` and `chef_solo_search_supported?` have been removed.
- Added a new API method `json_file_to_hash` for loading json files as a hash.
- Added a new rake command to run the regression test on just a single cookbook

**Fixed bugs:**

- Multiple rules have been rewritten to use Foodcritic APIs instead of using XPATH queries directly. This avoids false positives created by overly simplistic queries.
- Fixed FC069 to skip if the license metadata is any formatting of 'All Rights Reserved'.
- Added the `license` and `supermarket` tag to FC078.
- Updated the `field` and `field_value` API methods to correctly recognize additional formats of data in the metdata.

## [10.4.1](https://github.com/Foodcritic/foodcritic/tree/v10.4.1) (2017-04-17)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/v10.4.0...v10.4.1)

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

## [10.4.0](https://github.com/Foodcritic/foodcritic/tree/v10.4.0) (2017-04-13)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/v10.3.1...v10.4.0)

**Implemented enhancements:**

- Added FC076 to alert when the deprecated `conflicts` metadata is used
- Added FC077 to alert when the deprecated `replaces` metadata is used
- Added FC078 to alert when a non-OSI-approved license is used in metadata. You can disable this rule turning off the new `opensource` tag. For example: `foodcritic -t ~opensource .`

**Fixed bugs:**

- Regression tests now ignore .foodcritic files so we see all possible failures
- FC053 / FC052 updated to properly refer the metadata as deprecated and not unimplemented
- FC071 no longer alerts when cookbooks are licensed as "All Rights Reserved"

## [10.3.1](https://github.com/Foodcritic/foodcritic/tree/v10.3.1) (2017-04-10)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/v10.3.0...v10.3.1)

**Implemented enhancements:**

- Added Chef 13.0.113 metadata, but retained 12.19.36 as the default

**Fixed bugs:**

- Resolved a regression when running Foodcritic as a Rake task

## [10.3.0](https://github.com/Foodcritic/foodcritic/tree/v10.3.0) (2017-04-10)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/v10.2.2...v10.3.0)

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

## [10.2.2](https://github.com/Foodcritic/foodcritic/tree/v10.2.2) (2017-03-31)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/v10.2.1...v10.2.2)

**Implemented enhancements:**

- Align rake setup better with CLI options to resolve bugs with tags in Rake [#533](https://github.com/Foodcritic/foodcritic/pull/533) ([tas50](https://github.com/tas50))

## [v10.2.1](https://github.com/Foodcritic/foodcritic/tree/v10.2.1) (2017-03-31)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/v10.2.0...v10.2.1)

**Implemented enhancements:**

- Add supermarket tag to FC067 and FC068 [#532](https://github.com/Foodcritic/foodcritic/pull/532) ([tas50](https://github.com/tas50))

## [v10.2.0](https://github.com/Foodcritic/foodcritic/tree/v10.2.0) (2017-03-30)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/v10.1.1...v10.2.0)

**Implemented enhancements:**

- Add FC066/FC067/FC068 to check metadata chef_version, license, and supports [#528](https://github.com/Foodcritic/foodcritic/pull/528) ([tas50](https://github.com/tas50))

**Fixed bugs:**

- Don't trigger FC007 on a shorthand recipe includes [#526](https://github.com/Foodcritic/foodcritic/pull/526) ([tas50](https://github.com/tas50))
- Fix already initialized constant warning with `--search-gems` [#529](https://github.com/Foodcritic/foodcritic/pull/529) ([nvwls](https://github.com/nvwls))

## [v10.1.1](https://github.com/Foodcritic/foodcritic/tree/v10.1.1) (2017-03-29)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/v10.1.0...v10.1.1)

**Fixed bugs:**

- Fix FC016 triggering on custom resources [#525](https://github.com/Foodcritic/foodcritic/pull/525) ([tas50](https://github.com/tas50))

## [v10.1.0](https://github.com/Foodcritic/foodcritic/tree/v10.1.0) (2017-03-29)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/v10.0.0...v10.1.0)

**Implemented enhancements:**

- Remove FC023 which is no longer considered best practice [#523](https://github.com/Foodcritic/foodcritic/pull/523) ([tas50](https://github.com/tas50))
- Add basic testing of the metadata_field api [#522](https://github.com/Foodcritic/foodcritic/pull/522) ([tas50](https://github.com/tas50))
- Add a more robust cookbook_base_path helper to the API [#520](https://github.com/Foodcritic/foodcritic/pull/520) ([tas50](https://github.com/tas50))
- Update various tags to better align the rules with the tag categories [#517](https://github.com/Foodcritic/foodcritic/pull/517) ([tas50](https://github.com/tas50))

## [v10.0.0](https://github.com/Foodcritic/foodcritic/tree/v10.0.0) (2017-03-14)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/v9.0.0...v10.0.0)

**Implemented enhancements:**

- Add 12.19 metadata as default and remove 12.0 - 12.5.1 [#516](https://github.com/Foodcritic/foodcritic/pull/516) ([tas50](https://github.com/tas50))
- Remove FC003 from Foodcritic [#512](https://github.com/Foodcritic/foodcritic/pull/512) ([tas50](https://github.com/tas50))

## [v9.0.0](https://github.com/Foodcritic/foodcritic/tree/v9.0.0) (2017-01-31)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/v8.2.0...v9.0.0)

**Implemented enhancements:**

- Add 12.18.31 metadata and make it the default [#508](https://github.com/Foodcritic/foodcritic/pull/508) ([tas50](https://github.com/tas50))
- Test on Ruby 2.4 and fix failing tests [#507](https://github.com/Foodcritic/foodcritic/pull/507) ([tas50](https://github.com/tas50))
- Support Chef RFC 17 compliant templates [#485](https://github.com/Foodcritic/foodcritic/pull/485) ([hagihala](https://github.com/hagihala))
- More sane default CLI values [#462](https://github.com/Foodcritic/foodcritic/pull/462) ([tas50](https://github.com/tas50))

## [v8.2.0](https://github.com/Foodcritic/foodcritic/tree/v8.2.0) (2017-01-09)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/v8.1.0...v8.2.0)

**Implemented enhancements:**

- Add 12.17.44 metadata (and make it the default) [#505](https://github.com/Foodcritic/foodcritic/pull/505) ([tas50](https://github.com/tas50))
- Add 12.16.42 metadata and make it the default [#497](https://github.com/Foodcritic/foodcritic/pull/497) ([tas50](https://github.com/tas50))

## [v8.1.0](https://github.com/Foodcritic/foodcritic/tree/v8.1.0) (2016-10-20)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/v8.0.0...v8.1.0)

**Implemented enhancements:**

- Add Chef client 12.15.19 metadata [#493](https://github.com/Foodcritic/foodcritic/pull/493) ([tas50](https://github.com/tas50))
- Clarify exclude path instructions in the CLI help [#489](https://github.com/Foodcritic/foodcritic/pull/489) ([unixorn](https://github.com/unixorn))

## [v8.0.0](https://github.com/Foodcritic/foodcritic/tree/v8.0.0) (2016-09-23)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/v7.1.0...v8.0.0)

**Implemented enhancements:**

- Require Ruby 2.2.2 [#487](https://github.com/Foodcritic/foodcritic/pull/487) ([tas50](https://github.com/tas50))
- Add 12.14.89 metadata and make it the default [#486](https://github.com/Foodcritic/foodcritic/pull/486) ([tas50](https://github.com/tas50))
- Remove Chef 11 metadata and rule support [#481](https://github.com/Foodcritic/foodcritic/pull/481) ([tas50](https://github.com/tas50))

## [v7.1.0](https://github.com/Foodcritic/foodcritic/tree/v7.1.0) (2016-08-17)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/v7.0.1...v7.1.0)

**Implemented enhancements:**

- Add Chef 12.13.37 metadata and make it the default [#479](https://github.com/Foodcritic/foodcritic/pull/479) ([tas50](https://github.com/tas50))
- Add 12.12.13 metadata and fix metadata generation [#472](https://github.com/Foodcritic/foodcritic/pull/472) ([tas50](https://github.com/tas50))

**Fixed bugs:**

- Add missing assigment attributes [#478](https://github.com/Foodcritic/foodcritic/pull/478) ([ofir-petrushka](https://github.com/ofir-petrushka))

## [v7.0.1](https://github.com/Foodcritic/foodcritic/tree/v7.0.1) (2016-07-06)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/v7.0.0...v7.0.1)

**Implemented enhancements:**

- Readme improvements [#468](https://github.com/Foodcritic/foodcritic/pull/468) ([tas50](https://github.com/tas50))

## [v7.0.0](https://github.com/Foodcritic/foodcritic/tree/v7.0.0) (2016-07-05)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/v6.3.0...v7.0.0)

**Implemented enhancements:**

- Remove support for Ruby 2.0 [#465](https://github.com/Foodcritic/foodcritic/pull/465) ([tas50](https://github.com/tas50))
- Remove chef version support for Chef 0.7, 0.8, 0.9, and 0.10 [#464](https://github.com/Foodcritic/foodcritic/pull/464) ([tas50](https://github.com/tas50))
- Add chef 12.11.18 metadata and make it the default [#461](https://github.com/Foodcritic/foodcritic/pull/461) ([tas50](https://github.com/tas50))
- FC032 allow the new :before timing on resource notifications in Chef >= 12.6.0 [#441](https://github.com/Foodcritic/foodcritic/pull/441) ([gnjack](https://github.com/gnjack))
- New cookbook_maintainer api methods [#248](https://github.com/Foodcritic/foodcritic/pull/248) ([miguelcnf](https://github.com/miguelcnf))

## [v6.3.0](https://github.com/Foodcritic/foodcritic/tree/v6.3.0) (2016-05-16)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/v6.2.0...v6.3.0)

**Implemented enhancements:**

- Add Chef 12.10.24 metadata and release 6.3.0 [#456](https://github.com/Foodcritic/foodcritic/pull/456) ([tas50](https://github.com/tas50))

## [v6.2.0](https://github.com/Foodcritic/foodcritic/tree/v6.2.0) (2016-04-26)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/v6.1.1...v6.2.0)

**Implemented enhancements:**

- Add 12.9.38 metadata and make it the default chef version [#452](https://github.com/Foodcritic/foodcritic/pull/452) ([tas50](https://github.com/tas50))

## [v6.1.1](https://github.com/Foodcritic/foodcritic/tree/v6.1.1) (2016-04-08)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/v6.1.0...v6.1.1)

**Implemented enhancements:**

- Use latest gherkin for faster installs [#447](https://github.com/Foodcritic/foodcritic/pull/447) ([jkeiser](https://github.com/jkeiser))

## [v6.1.0](https://github.com/Foodcritic/foodcritic/tree/v6.1.0) (2016-04-06)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/v6.0.1...v6.1.0)

**Implemented enhancements:**

- Don't require cucumber and rubocop to run rake [#444](https://github.com/Foodcritic/foodcritic/pull/444) ([jkeiser](https://github.com/jkeiser))
- Add 12.8.1 metadata + update metadata process [#438](https://github.com/Foodcritic/foodcritic/pull/438) ([tas50](https://github.com/tas50))
- Add metadata for Chef 12.7.2 and update instructions [#427](https://github.com/Foodcritic/foodcritic/pull/427) ([tas50](https://github.com/tas50))

**Fixed bugs:**

- Rake.last_comment was depreciated in Rake11\. [#434](https://github.com/Foodcritic/foodcritic/pull/434) ([gkuchta](https://github.com/gkuchta))

## [v6.0.1](https://github.com/Foodcritic/foodcritic/tree/v6.0.1) (2016-02-22)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/v6.0.0...v6.0.1)

**Implemented enhancements:**

- Check for URLs that are helpful to the Supermarket [#421](https://github.com/Foodcritic/foodcritic/pull/421) ([nathenharvey](https://github.com/nathenharvey))

**Fixed bugs:**

- Fix FC058 false positives [#423](https://github.com/Foodcritic/foodcritic/pull/423) ([jaym](https://github.com/jaym))

## [v6.0.0](https://github.com/Foodcritic/foodcritic/tree/v6.0.0) (2016-01-14)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/v5.0.0...v6.0.0)

**Implemented enhancements:**

- Cookbook version is specified in metadata [#347](https://github.com/Foodcritic/foodcritic/issues/347)
- FC035 - Templates, Style [#62](https://github.com/Foodcritic/foodcritic/issues/62)
- Add Chef 12.6.0 metadata [#417](https://github.com/Foodcritic/foodcritic/pull/417) ([tas50](https://github.com/tas50))
- New Rule 61 - valid cookbook version [#405](https://github.com/Foodcritic/foodcritic/pull/405) ([lamont-granquist](https://github.com/lamont-granquist))
- Require Oracle as a RHEL equiv [#404](https://github.com/Foodcritic/foodcritic/pull/404) ([tas50](https://github.com/tas50))
- Suggest updating from definitions to custom resources [#403](https://github.com/Foodcritic/foodcritic/pull/403) ([tas50](https://github.com/tas50))
- add checks for correct use of use_inline_resources [#402](https://github.com/Foodcritic/foodcritic/pull/402) ([lamont-granquist](https://github.com/lamont-granquist))
- Add new tags for rules [#401](https://github.com/Foodcritic/foodcritic/pull/401) ([tas50](https://github.com/tas50))
- Rename FC045 since Chef 12 requires name metadata [#399](https://github.com/Foodcritic/foodcritic/pull/399) ([tas50](https://github.com/tas50))
- Add Chef 12.5.1 metadata [#397](https://github.com/Foodcritic/foodcritic/pull/397) ([tas50](https://github.com/tas50))
- Add self-dependency warning [#328](https://github.com/Foodcritic/foodcritic/pull/328) ([lamont-granquist](https://github.com/lamont-granquist))

**Fixed bugs:**

- Time to cut a release? [#344](https://github.com/Foodcritic/foodcritic/issues/344)
- FC048: Warn within a provider block, refs #365 [#413](https://github.com/Foodcritic/foodcritic/pull/413) ([acrmp](https://github.com/Foodcritic))
- use_inline_resources checks apply to Chef 11+ [#410](https://github.com/Foodcritic/foodcritic/pull/410) ([tas50](https://github.com/tas50))
- fix for edge condition with 061 [#408](https://github.com/Foodcritic/foodcritic/pull/408) ([lamont-granquist](https://github.com/lamont-granquist))
- Rake options override default options [#382](https://github.com/Foodcritic/foodcritic/pull/382) ([pkang](https://github.com/pkang))

**Closed issues:**

- Chef Docs vs Foodcritic 4.x [#354](https://github.com/Foodcritic/foodcritic/issues/354)
- Github pages have drifted from foodcritic.io [#332](https://github.com/Foodcritic/foodcritic/issues/332)
- FC001 is re-enabled thus <http://www.foodcritic.io/> is out-of-date [#330](https://github.com/Foodcritic/foodcritic/issues/330)

## [v5.0.0](https://github.com/Foodcritic/foodcritic/tree/v5.0.0) (2015-09-17)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/v4.0.0...v5.0.0)

**Implemented enhancements:**

- Support for a magic comment to temporarily disable a rule [#259](https://github.com/Foodcritic/foodcritic/issues/259)
- FC007 false positive on depending on the cookbook currently being parsed [#242](https://github.com/Foodcritic/foodcritic/issues/242)
- Create a rule for "execute resource used to install packages" [#180](https://github.com/Foodcritic/foodcritic/issues/180)
- New Rule Proposal: uid/gid should be integer [#53](https://github.com/Foodcritic/foodcritic/issues/53)
- merge default options before check instead of during intialization [#321](https://github.com/Foodcritic/foodcritic/pull/321) ([ranjib](https://github.com/ranjib))

**Fixed bugs:**

- Fix FC031 and FC045 and metadata.rb vs metadata.json issues [#369](https://github.com/Foodcritic/foodcritic/issues/369)
- FC007 false positive on depending on the cookbook currently being parsed [#242](https://github.com/Foodcritic/foodcritic/issues/242)
- FC010 Test failures due to missing search support [#199](https://github.com/Foodcritic/foodcritic/issues/199)
- 'lazy' causes false-positive in FC009 - on previous line [#189](https://github.com/Foodcritic/foodcritic/issues/189)
- FC051 tries to validate temp files of the editors [#172](https://github.com/Foodcritic/foodcritic/issues/172)

## [v4.0.0](https://github.com/Foodcritic/foodcritic/tree/v4.0.0) (2014-06-11)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/v3.0.3...v4.0.0)

## [v3.0.3](https://github.com/Foodcritic/foodcritic/tree/v3.0.3) (2013-10-13)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/v3.0.2...v3.0.3)

## [v3.0.2](https://github.com/Foodcritic/foodcritic/tree/v3.0.2) (2013-10-05)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/v3.0.1...v3.0.2)

## [v3.0.1](https://github.com/Foodcritic/foodcritic/tree/v3.0.1) (2013-09-25)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/v3.0.0...v3.0.1)

**Implemented enhancements:**

- Roles rules [#19](https://github.com/Foodcritic/foodcritic/issues/19)

## [v3.0.0](https://github.com/Foodcritic/foodcritic/tree/v3.0.0) (2013-09-14)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/v2.2.0...v3.0.0)

**Implemented enhancements:**

- Provide a comprehensive list of `tags` somewhere on the docs [#63](https://github.com/Foodcritic/foodcritic/issues/63)

**Fixed bugs:**

- FC001, FC019 shouldn't match on node.run_state [#66](https://github.com/Foodcritic/foodcritic/issues/66)

## [v2.2.0](https://github.com/Foodcritic/foodcritic/tree/v2.2.0) (2013-07-10)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/v2.1.0...v2.2.0)

## [v2.1.0](https://github.com/Foodcritic/foodcritic/tree/v2.1.0) (2013-04-16)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/v2.0.1...v2.1.0)

**Implemented enhancements:**

- New Rule Proposal: ||= considered harmful with attributes [#52](https://github.com/Foodcritic/foodcritic/issues/52)
- Would like to be able to exempt rules in cookbooks [#10](https://github.com/Foodcritic/foodcritic/issues/10)

## [v2.0.1](https://github.com/Foodcritic/foodcritic/tree/v2.0.1) (2013-03-31)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/v2.0.0...v2.0.1)

## [v2.0.0](https://github.com/Foodcritic/foodcritic/tree/v2.0.0) (2013-03-24)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/v1.7.0...v2.0.0)

**Implemented enhancements:**

- New Rule: Check for existence of 'name' in metadata.rb [#64](https://github.com/Foodcritic/foodcritic/issues/64)
- New Rule: action ":none" vs ":nothing" [#61](https://github.com/Foodcritic/foodcritic/issues/61)

**Fixed bugs:**

- Incorrectly decoding attributes within a block [#76](https://github.com/Foodcritic/foodcritic/issues/76)
- FC003 doesn't match unless statements [#58](https://github.com/Foodcritic/foodcritic/issues/58)
- FC019 triggered on internal recipe hash key as symbol instead of node [#54](https://github.com/Foodcritic/foodcritic/issues/54)

## [v1.7.0](https://github.com/Foodcritic/foodcritic/tree/v1.7.0) (2012-12-27)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/v1.6.1...v1.7.0)

**Fixed bugs:**

- FC037 false positive for subscribes [#65](https://github.com/Foodcritic/foodcritic/issues/65)
- Foodcritic not being fully deterministic. [#55](https://github.com/Foodcritic/foodcritic/issues/55)

## [v1.6.1](https://github.com/Foodcritic/foodcritic/tree/v1.6.1) (2012-08-30)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/v1.6.0...v1.6.1)

## [v1.6.0](https://github.com/Foodcritic/foodcritic/tree/v1.6.0) (2012-08-28)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/v1.5.0...v1.6.0)

**Implemented enhancements:**

- Thoughts on more style-y lint checks [#15](https://github.com/Foodcritic/foodcritic/issues/15)

**Fixed bugs:**

- FC020 triggered on non-ruby shell command [#30](https://github.com/Foodcritic/foodcritic/issues/30)
- Incorrect FC019 alarms [#22](https://github.com/Foodcritic/foodcritic/issues/22)

## [v1.5.0](https://github.com/Foodcritic/foodcritic/tree/v1.5.0) (2012-08-20)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/v1.5.1...v1.5.0)

## [v1.5.1](https://github.com/Foodcritic/foodcritic/tree/v1.5.1) (2012-08-20)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/v1.4.0...v1.5.1)

**Fixed bugs:**

- FC007 should not be triggered by include_recipe "#{cookbook_name}::blah" [#44](https://github.com/Foodcritic/foodcritic/issues/44)
- FC022 block name check appears to be too simplistic [#29](https://github.com/Foodcritic/foodcritic/issues/29)

## [v1.4.0](https://github.com/Foodcritic/foodcritic/tree/v1.4.0) (2012-06-15)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/v1.3.1...v1.4.0)

## [v1.3.1](https://github.com/Foodcritic/foodcritic/tree/v1.3.1) (2012-06-09)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/v1.3.0...v1.3.1)

**Implemented enhancements:**

- catch pry breakpoints [#36](https://github.com/Foodcritic/foodcritic/issues/36)

**Fixed bugs:**

- resource_attributes should show all of the relevant part of the AST [#31](https://github.com/Foodcritic/foodcritic/issues/31)
- FC003 is triggered, despite being handled [#26](https://github.com/Foodcritic/foodcritic/issues/26)

## [v1.3.0](https://github.com/Foodcritic/foodcritic/tree/v1.3.0) (2012-05-21)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/v1.2.0...v1.3.0)

## [v1.2.0](https://github.com/Foodcritic/foodcritic/tree/v1.2.0) (2012-04-21)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/v1.1.0...v1.2.0)

## [v1.1.0](https://github.com/Foodcritic/foodcritic/tree/v1.1.0) (2012-03-25)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/v1.0.1...v1.1.0)

**Fixed bugs:**

- ruby segfault / foodcritic 1.0.0 / nokogiri 1.5.2 [#18](https://github.com/Foodcritic/foodcritic/issues/18)

## [v1.0.1](https://github.com/Foodcritic/foodcritic/tree/v1.0.1) (2012-03-15)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/v1.0.0...v1.0.1)

**Implemented enhancements:**

- rules in code? [#8](https://github.com/Foodcritic/foodcritic/issues/8)

## [v1.0.0](https://github.com/Foodcritic/foodcritic/tree/v1.0.0) (2012-03-04)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/v0.11.1...v1.0.0)

**Implemented enhancements:**

- Foodcritic doesn't have a -v [#16](https://github.com/Foodcritic/foodcritic/issues/16)

**Fixed bugs:**

- FC003: Recognise updated chef-solo-search [#17](https://github.com/Foodcritic/foodcritic/issues/17)
- foodcritic v10 and v11 have conflicting yajl-ruby dependencies with chef [#14](https://github.com/Foodcritic/foodcritic/issues/14)

## [v0.11.1](https://github.com/Foodcritic/foodcritic/tree/v0.11.1) (2012-02-29)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/v0.11.0...v0.11.1)

**Implemented enhancements:**

- Want "all" arg to '-f' option. [#11](https://github.com/Foodcritic/foodcritic/issues/11)

**Fixed bugs:**

- Epic fail fail? [#13](https://github.com/Foodcritic/foodcritic/issues/13)

## [v0.11.0](https://github.com/Foodcritic/foodcritic/tree/v0.11.0) (2012-02-22)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/v0.10.0...v0.11.0)

**Fixed bugs:**

- Numeric value for mode should be 5 digits (CHEF-174) [#9](https://github.com/Foodcritic/foodcritic/pull/9) ([aia](https://github.com/aia))

## [v0.10.0](https://github.com/Foodcritic/foodcritic/tree/v0.10.0) (2012-02-20)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/v0.9.0...v0.10.0)

## [v0.9.0](https://github.com/Foodcritic/foodcritic/tree/v0.9.0) (2012-01-26)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/v0.8.1...v0.9.0)

## [v0.8.1](https://github.com/Foodcritic/foodcritic/tree/v0.8.1) (2012-01-20)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/v0.8.0...v0.8.1)

## [v0.8.0](https://github.com/Foodcritic/foodcritic/tree/v0.8.0) (2012-01-19)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/v0.7.0...v0.8.0)

**Fixed bugs:**

- Don't raise FC003 warning if chef-solo-search is installed [#7](https://github.com/Foodcritic/foodcritic/issues/7)

## [v0.7.0](https://github.com/Foodcritic/foodcritic/tree/v0.7.0) (2011-12-31)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/v0.6.0...v0.7.0)

## [v0.6.0](https://github.com/Foodcritic/foodcritic/tree/v0.6.0) (2011-12-18)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/v0.5.2...v0.6.0)

**Fixed bugs:**

- Bundler fails to resolve JSON version [#6](https://github.com/Foodcritic/foodcritic/issues/6)

## [v0.5.2](https://github.com/Foodcritic/foodcritic/tree/v0.5.2) (2011-12-15)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/v0.5.1...v0.5.2)

## [v0.5.1](https://github.com/Foodcritic/foodcritic/tree/v0.5.1) (2011-12-14)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/v0.5.0...v0.5.1)

## [v0.5.0](https://github.com/Foodcritic/foodcritic/tree/v0.5.0) (2011-12-13)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/v0.4.0...v0.5.0)

## [v0.4.0](https://github.com/Foodcritic/foodcritic/tree/v0.4.0) (2011-12-10)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/v0.3.0...v0.4.0)

## [v0.3.0](https://github.com/Foodcritic/foodcritic/tree/v0.3.0) (2011-12-04)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/v0.2.0...v0.3.0)

## [v0.2.0](https://github.com/Foodcritic/foodcritic/tree/v0.2.0) (2011-12-01)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/v0.1.0...v0.2.0)

## [v0.1.0](https://github.com/Foodcritic/foodcritic/tree/v0.1.0) (2011-11-30)

[Full Changelog](https://github.com/Foodcritic/foodcritic/compare/4257264aa0bf93e3d13851ac0343a6b25ca3d316...v0.1.0)

- _This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)_
