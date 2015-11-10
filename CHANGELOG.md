# Change Log

## [Unreleased](https://github.com/acrmp/foodcritic/tree/HEAD)

[Full Changelog](https://github.com/acrmp/foodcritic/compare/v5.0.0...HEAD)

**Merged pull requests:**

- New Rule 61 - valid cookbook version [\#405](https://github.com/acrmp/foodcritic/pull/405) ([lamont-granquist](https://github.com/lamont-granquist))
- Suggest updating from definitions to custom resources [\#403](https://github.com/acrmp/foodcritic/pull/403) ([tas50](https://github.com/tas50))
- add checks for correct use of use\_inline\_resources [\#402](https://github.com/acrmp/foodcritic/pull/402) ([lamont-granquist](https://github.com/lamont-granquist))
- Add new tags for rules [\#401](https://github.com/acrmp/foodcritic/pull/401) ([tas50](https://github.com/tas50))
- We require Ruby 2 now so unpin mustache [\#400](https://github.com/acrmp/foodcritic/pull/400) ([tas50](https://github.com/tas50))
- Rename FC045 since Chef 12 requires name metadata [\#399](https://github.com/acrmp/foodcritic/pull/399) ([tas50](https://github.com/tas50))
- Branding updates [\#398](https://github.com/acrmp/foodcritic/pull/398) ([tas50](https://github.com/tas50))
- Add Chef 12.5.1 metadata [\#397](https://github.com/acrmp/foodcritic/pull/397) ([tas50](https://github.com/tas50))
- FC 5.0 has been released.  Update changelog [\#396](https://github.com/acrmp/foodcritic/pull/396) ([tas50](https://github.com/tas50))
- remove duplicate output [\#394](https://github.com/acrmp/foodcritic/pull/394) ([dwradcliffe](https://github.com/dwradcliffe))
- Rake options override default options [\#382](https://github.com/acrmp/foodcritic/pull/382) ([pkang](https://github.com/pkang))
- Fixed the rake man task [\#381](https://github.com/acrmp/foodcritic/pull/381) ([docwhat](https://github.com/docwhat))
- Update foodcritic.gemspec [\#380](https://github.com/acrmp/foodcritic/pull/380) ([tas50](https://github.com/tas50))

## [v5.0.0](https://github.com/acrmp/foodcritic/tree/v5.0.0) (2015-09-17)
[Full Changelog](https://github.com/acrmp/foodcritic/compare/v4.0.0...v5.0.0)

**Merged pull requests:**

- Lcg/fc054 revert again [\#379](https://github.com/acrmp/foodcritic/pull/379) ([lamont-granquist](https://github.com/lamont-granquist))
- catch the CHANGELOG up to v5.0.0 [\#378](https://github.com/acrmp/foodcritic/pull/378) ([lamont-granquist](https://github.com/lamont-granquist))
- remove 1.9.3 support [\#377](https://github.com/acrmp/foodcritic/pull/377) ([lamont-granquist](https://github.com/lamont-granquist))
- fix FC054 [\#376](https://github.com/acrmp/foodcritic/pull/376) ([lamont-granquist](https://github.com/lamont-granquist))
- fixes for cookbooks.txt and expected-output.txt [\#375](https://github.com/acrmp/foodcritic/pull/375) ([lamont-granquist](https://github.com/lamont-granquist))
- Revert "Merge pull request \#358 from acrmp/lcg/revert-FC054" [\#374](https://github.com/acrmp/foodcritic/pull/374) ([lamont-granquist](https://github.com/lamont-granquist))
- Update CHANGELOG.md [\#368](https://github.com/acrmp/foodcritic/pull/368) ([tas50](https://github.com/tas50))
- Updates to the regressions files [\#366](https://github.com/acrmp/foodcritic/pull/366) ([tas50](https://github.com/tas50))
- support Chef::Node::Attribute methods [\#364](https://github.com/acrmp/foodcritic/pull/364) ([lamont-granquist](https://github.com/lamont-granquist))
- update CHANGELOG.md for DSL updates [\#363](https://github.com/acrmp/foodcritic/pull/363) ([lamont-granquist](https://github.com/lamont-granquist))
- FC009 chef metadata update [\#362](https://github.com/acrmp/foodcritic/pull/362) ([lamont-granquist](https://github.com/lamont-granquist))
- Update regression testing [\#361](https://github.com/acrmp/foodcritic/pull/361) ([tas50](https://github.com/tas50))
- Fix the other names [\#360](https://github.com/acrmp/foodcritic/pull/360) ([tas50](https://github.com/tas50))
- Update travis badge, add gem version badge [\#359](https://github.com/acrmp/foodcritic/pull/359) ([tas50](https://github.com/tas50))
- Revert "FC054, check for mismatched cookbook names" [\#358](https://github.com/acrmp/foodcritic/pull/358) ([lamont-granquist](https://github.com/lamont-granquist))
- let chef gem follow latest 12.x version [\#357](https://github.com/acrmp/foodcritic/pull/357) ([lamont-granquist](https://github.com/lamont-granquist))
- some travis.yml fixes [\#356](https://github.com/acrmp/foodcritic/pull/356) ([lamont-granquist](https://github.com/lamont-granquist))
- Fix flagging directory symlinks [\#348](https://github.com/acrmp/foodcritic/pull/348) ([odcinek](https://github.com/odcinek))
- Add output to built-in rake task [\#342](https://github.com/acrmp/foodcritic/pull/342) ([patcon](https://github.com/patcon))
- merge default options before check instead of during intialization [\#321](https://github.com/acrmp/foodcritic/pull/321) ([ranjib](https://github.com/ranjib))
- Update README.md [\#319](https://github.com/acrmp/foodcritic/pull/319) ([jjasghar](https://github.com/jjasghar))
- Sanitize template input [\#317](https://github.com/acrmp/foodcritic/pull/317) ([odcinek](https://github.com/odcinek))
- Default to recent chef version [\#315](https://github.com/acrmp/foodcritic/pull/315) ([odcinek](https://github.com/odcinek))
- Make FC041 smarter about CURL usage [\#313](https://github.com/acrmp/foodcritic/pull/313) ([odcinek](https://github.com/odcinek))
- Recognize force\_default and force\_override. [\#312](https://github.com/acrmp/foodcritic/pull/312) ([coderanger](https://github.com/coderanger))
- Add chef 12.0.0 through 12.1.1 [\#311](https://github.com/acrmp/foodcritic/pull/311) ([odcinek](https://github.com/odcinek))
- Fix FC002 for heredoc on ruby 2.2 [\#310](https://github.com/acrmp/foodcritic/pull/310) ([odcinek](https://github.com/odcinek))
- add warnings for use of recommends/suggests [\#309](https://github.com/acrmp/foodcritic/pull/309) ([lamont-granquist](https://github.com/lamont-granquist))
- Lcg/changelog updates [\#304](https://github.com/acrmp/foodcritic/pull/304) ([lamont-granquist](https://github.com/lamont-granquist))
- Cloudkick no more [\#303](https://github.com/acrmp/foodcritic/pull/303) ([lamont-granquist](https://github.com/lamont-granquist))
- Add metadata for missing chef 11 versions [\#294](https://github.com/acrmp/foodcritic/pull/294) ([jaym](https://github.com/jaym))
- Upgrade nokogiri dependency to support traveling-ruby nokogiri 1.6.5 [\#291](https://github.com/acrmp/foodcritic/pull/291) ([drnic](https://github.com/drnic))
- Another try to make the pages build. [\#288](https://github.com/acrmp/foodcritic/pull/288) ([jaymzh](https://github.com/jaymzh))
- Move to kramdown for gh-pages. [\#287](https://github.com/acrmp/foodcritic/pull/287) ([jaymzh](https://github.com/jaymzh))
- Features/list rules [\#285](https://github.com/acrmp/foodcritic/pull/285) ([clintoncwolfe](https://github.com/clintoncwolfe))
- Handle flagging binary files properly [\#283](https://github.com/acrmp/foodcritic/pull/283) ([odcinek](https://github.com/odcinek))
- FC054, Name should match cookbook dir name in metadata [\#282](https://github.com/acrmp/foodcritic/pull/282) ([odcinek](https://github.com/odcinek))
- Handle system attribute of user resource correctly [\#281](https://github.com/acrmp/foodcritic/pull/281) ([odcinek](https://github.com/odcinek))
- Make FC044 not false positive on parameterized attributes [\#280](https://github.com/acrmp/foodcritic/pull/280) ([odcinek](https://github.com/odcinek))
- tests: make simplecov optional [\#276](https://github.com/acrmp/foodcritic/pull/276) ([ktdreyer](https://github.com/ktdreyer))
- Reinstate FC001 [\#251](https://github.com/acrmp/foodcritic/pull/251) ([juliandunn](https://github.com/juliandunn))
- Show progress with --progress [\#244](https://github.com/acrmp/foodcritic/pull/244) ([justincampbell](https://github.com/justincampbell))
- Update faq.md [\#228](https://github.com/acrmp/foodcritic/pull/228) ([danleyden](https://github.com/danleyden))

## [v4.0.0](https://github.com/acrmp/foodcritic/tree/v4.0.0) (2014-06-11)
[Full Changelog](https://github.com/acrmp/foodcritic/compare/v3.0.3...v4.0.0)

**Merged pull requests:**

- FC047 triggers when override! and default! are used [\#226](https://github.com/acrmp/foodcritic/pull/226) ([v-a](https://github.com/v-a))
- add chef 11.6.2 through 11.10.4 [\#220](https://github.com/acrmp/foodcritic/pull/220) ([lamont-granquist](https://github.com/lamont-granquist))
- relax nokogiri gemspec pinning [\#217](https://github.com/acrmp/foodcritic/pull/217) ([lamont-granquist](https://github.com/lamont-granquist))
- Fix issue 185 [\#213](https://github.com/acrmp/foodcritic/pull/213) ([zts](https://github.com/zts))
- FC006: don't fail when mode specified as array ref [\#212](https://github.com/acrmp/foodcritic/pull/212) ([zts](https://github.com/zts))
- Add Ruby 2.1.0 to .travis.yml [\#209](https://github.com/acrmp/foodcritic/pull/209) ([petergoldstein](https://github.com/petergoldstein))
- gitignore: .bundle and tags [\#206](https://github.com/acrmp/foodcritic/pull/206) ([docwhat](https://github.com/docwhat))
- Rake task can use context output [\#204](https://github.com/acrmp/foodcritic/pull/204) ([docwhat](https://github.com/docwhat))
- Cache results of read\_ast call [\#200](https://github.com/acrmp/foodcritic/pull/200) ([dougbarth](https://github.com/dougbarth))
- Relax yajl-ruby dependency [\#197](https://github.com/acrmp/foodcritic/pull/197) ([elgalu](https://github.com/elgalu))
- Fix FC022 problem with definition [\#195](https://github.com/acrmp/foodcritic/pull/195) ([bpaquet](https://github.com/bpaquet))
- Improve Rake task [\#190](https://github.com/acrmp/foodcritic/pull/190) ([mlafeldt](https://github.com/mlafeldt))

## [v3.0.3](https://github.com/acrmp/foodcritic/tree/v3.0.3) (2013-10-13)
[Full Changelog](https://github.com/acrmp/foodcritic/compare/v3.0.2...v3.0.3)

## [v3.0.2](https://github.com/acrmp/foodcritic/tree/v3.0.2) (2013-10-05)
[Full Changelog](https://github.com/acrmp/foodcritic/compare/v3.0.1...v3.0.2)

## [v3.0.1](https://github.com/acrmp/foodcritic/tree/v3.0.1) (2013-09-25)
[Full Changelog](https://github.com/acrmp/foodcritic/compare/v3.0.0...v3.0.1)

## [v3.0.0](https://github.com/acrmp/foodcritic/tree/v3.0.0) (2013-09-14)
[Full Changelog](https://github.com/acrmp/foodcritic/compare/v2.2.0...v3.0.0)

**Merged pull requests:**

- Adding workaround for libxml2-2.6.26 xpath dup issue [\#163](https://github.com/acrmp/foodcritic/pull/163) ([danleyden](https://github.com/danleyden))
- Strip whitespace from depends [\#160](https://github.com/acrmp/foodcritic/pull/160) ([philk](https://github.com/philk))

## [v2.2.0](https://github.com/acrmp/foodcritic/tree/v2.2.0) (2013-07-10)
[Full Changelog](https://github.com/acrmp/foodcritic/compare/v2.1.0...v2.2.0)

**Merged pull requests:**

- Make it easier to differentiate failures from warnings [\#150](https://github.com/acrmp/foodcritic/pull/150) ([jamesdburgess](https://github.com/jamesdburgess))
- Manpage [\#147](https://github.com/acrmp/foodcritic/pull/147) ([stefanor](https://github.com/stefanor))
- Display context without rak [\#146](https://github.com/acrmp/foodcritic/pull/146) ([stefanor](https://github.com/stefanor))
- Include docs and LICENSE in the gem [\#145](https://github.com/acrmp/foodcritic/pull/145) ([stefanor](https://github.com/stefanor))
- Provide a search rubygems option to load custom rules from a gem. [\#143](https://github.com/acrmp/foodcritic/pull/143) ([rteabeault](https://github.com/rteabeault))
- Check definitions files [\#142](https://github.com/acrmp/foodcritic/pull/142) ([bpaquet](https://github.com/bpaquet))
- add feature: specify rule tags in any cookbook's .foodcritic file [\#141](https://github.com/acrmp/foodcritic/pull/141) ([sabat](https://github.com/sabat))

## [v2.1.0](https://github.com/acrmp/foodcritic/tree/v2.1.0) (2013-04-16)
[Full Changelog](https://github.com/acrmp/foodcritic/compare/v2.0.1...v2.1.0)

**Merged pull requests:**

- Fix deprecation warnings from Gherkin [\#122](https://github.com/acrmp/foodcritic/pull/122) ([tmatilai](https://github.com/tmatilai))

## [v2.0.1](https://github.com/acrmp/foodcritic/tree/v2.0.1) (2013-03-31)
[Full Changelog](https://github.com/acrmp/foodcritic/compare/v2.0.0...v2.0.1)

## [v2.0.0](https://github.com/acrmp/foodcritic/tree/v2.0.0) (2013-03-24)
[Full Changelog](https://github.com/acrmp/foodcritic/compare/v1.7.0...v2.0.0)

**Merged pull requests:**

- ignore rules via comment on the offending line [\#116](https://github.com/acrmp/foodcritic/pull/116) ([grosser](https://github.com/grosser))

## [v1.7.0](https://github.com/acrmp/foodcritic/tree/v1.7.0) (2012-12-27)
[Full Changelog](https://github.com/acrmp/foodcritic/compare/v1.6.1...v1.7.0)

**Merged pull requests:**

- parse :'symbol' notification actions [\#94](https://github.com/acrmp/foodcritic/pull/94) ([ohm](https://github.com/ohm))
- Add spec/\*\*/\* and features/\*\*/\* to default rake task :exclude\_paths. [\#84](https://github.com/acrmp/foodcritic/pull/84) ([fnichol](https://github.com/fnichol))
- Reduce unnecessary blank lines from console output if there's nothing to print [\#78](https://github.com/acrmp/foodcritic/pull/78) ([ketan](https://github.com/ketan))
- FC042: Prefer include\_recipe [\#77](https://github.com/acrmp/foodcritic/pull/77) ([pwelch](https://github.com/pwelch))
- Do not require an empty array if just using default options [\#71](https://github.com/acrmp/foodcritic/pull/71) ([kreynolds](https://github.com/kreynolds))

## [v1.6.1](https://github.com/acrmp/foodcritic/tree/v1.6.1) (2012-08-30)
[Full Changelog](https://github.com/acrmp/foodcritic/compare/v1.6.0...v1.6.1)

## [v1.6.0](https://github.com/acrmp/foodcritic/tree/v1.6.0) (2012-08-28)
[Full Changelog](https://github.com/acrmp/foodcritic/compare/v1.5.0...v1.6.0)

## [v1.5.0](https://github.com/acrmp/foodcritic/tree/v1.5.0) (2012-08-20)
[Full Changelog](https://github.com/acrmp/foodcritic/compare/v1.5.1...v1.5.0)

## [v1.5.1](https://github.com/acrmp/foodcritic/tree/v1.5.1) (2012-08-20)
[Full Changelog](https://github.com/acrmp/foodcritic/compare/v1.4.0...v1.5.1)

**Merged pull requests:**

- Avoid to show version with -v plus some argument is passed [\#47](https://github.com/acrmp/foodcritic/pull/47) ([juanje](https://github.com/juanje))
- Add help message when invalid option is passed [\#46](https://github.com/acrmp/foodcritic/pull/46) ([juanje](https://github.com/juanje))

## [v1.4.0](https://github.com/acrmp/foodcritic/tree/v1.4.0) (2012-06-15)
[Full Changelog](https://github.com/acrmp/foodcritic/compare/v1.3.1...v1.4.0)

## [v1.3.1](https://github.com/acrmp/foodcritic/tree/v1.3.1) (2012-06-09)
[Full Changelog](https://github.com/acrmp/foodcritic/compare/v1.3.0...v1.3.1)

**Merged pull requests:**

- FC031: Cookbook without metadata file [\#43](https://github.com/acrmp/foodcritic/pull/43) ([juanje](https://github.com/juanje))
- Initial getting-started docs for using tailor [\#42](https://github.com/acrmp/foodcritic/pull/42) ([turboladen](https://github.com/turboladen))
- \[GH-26\] Final case of method access [\#39](https://github.com/acrmp/foodcritic/pull/39) ([miketheman](https://github.com/miketheman))

## [v1.3.0](https://github.com/acrmp/foodcritic/tree/v1.3.0) (2012-05-21)
[Full Changelog](https://github.com/acrmp/foodcritic/compare/v1.2.0...v1.3.0)

**Merged pull requests:**

- Added integration test for linting individual files [\#33](https://github.com/acrmp/foodcritic/pull/33) ([cgriego](https://github.com/cgriego))
- Allow linting of individual files [\#32](https://github.com/acrmp/foodcritic/pull/32) ([cgriego](https://github.com/cgriego))
- Better handling of Chef::Config solo variants, refs \#26 [\#28](https://github.com/acrmp/foodcritic/pull/28) ([miketheman](https://github.com/miketheman))

## [v1.2.0](https://github.com/acrmp/foodcritic/tree/v1.2.0) (2012-04-21)
[Full Changelog](https://github.com/acrmp/foodcritic/compare/v1.1.0...v1.2.0)

## [v1.1.0](https://github.com/acrmp/foodcritic/tree/v1.1.0) (2012-03-25)
[Full Changelog](https://github.com/acrmp/foodcritic/compare/v1.0.1...v1.1.0)

## [v1.0.1](https://github.com/acrmp/foodcritic/tree/v1.0.1) (2012-03-15)
[Full Changelog](https://github.com/acrmp/foodcritic/compare/v1.0.0...v1.0.1)

## [v1.0.0](https://github.com/acrmp/foodcritic/tree/v1.0.0) (2012-03-04)
[Full Changelog](https://github.com/acrmp/foodcritic/compare/v0.11.1...v1.0.0)

## [v0.11.1](https://github.com/acrmp/foodcritic/tree/v0.11.1) (2012-02-29)
[Full Changelog](https://github.com/acrmp/foodcritic/compare/v0.11.0...v0.11.1)

## [v0.11.0](https://github.com/acrmp/foodcritic/tree/v0.11.0) (2012-02-22)
[Full Changelog](https://github.com/acrmp/foodcritic/compare/v0.10.0...v0.11.0)

**Merged pull requests:**

- Updating the rule to treat 0xxx modes as valid [\#12](https://github.com/acrmp/foodcritic/pull/12) ([aia](https://github.com/aia))
- Numeric value for mode should be 5 digits \(CHEF-174\) [\#9](https://github.com/acrmp/foodcritic/pull/9) ([aia](https://github.com/aia))

## [v0.10.0](https://github.com/acrmp/foodcritic/tree/v0.10.0) (2012-02-20)
[Full Changelog](https://github.com/acrmp/foodcritic/compare/v0.9.0...v0.10.0)

## [v0.9.0](https://github.com/acrmp/foodcritic/tree/v0.9.0) (2012-01-26)
[Full Changelog](https://github.com/acrmp/foodcritic/compare/v0.8.1...v0.9.0)

## [v0.8.1](https://github.com/acrmp/foodcritic/tree/v0.8.1) (2012-01-20)
[Full Changelog](https://github.com/acrmp/foodcritic/compare/v0.8.0...v0.8.1)

## [v0.8.0](https://github.com/acrmp/foodcritic/tree/v0.8.0) (2012-01-19)
[Full Changelog](https://github.com/acrmp/foodcritic/compare/v0.7.0...v0.8.0)

## [v0.7.0](https://github.com/acrmp/foodcritic/tree/v0.7.0) (2011-12-31)
[Full Changelog](https://github.com/acrmp/foodcritic/compare/v0.6.0...v0.7.0)

## [v0.6.0](https://github.com/acrmp/foodcritic/tree/v0.6.0) (2011-12-18)
[Full Changelog](https://github.com/acrmp/foodcritic/compare/v0.5.2...v0.6.0)

## [v0.5.2](https://github.com/acrmp/foodcritic/tree/v0.5.2) (2011-12-15)
[Full Changelog](https://github.com/acrmp/foodcritic/compare/v0.5.1...v0.5.2)

## [v0.5.1](https://github.com/acrmp/foodcritic/tree/v0.5.1) (2011-12-14)
[Full Changelog](https://github.com/acrmp/foodcritic/compare/v0.5.0...v0.5.1)

## [v0.5.0](https://github.com/acrmp/foodcritic/tree/v0.5.0) (2011-12-13)
[Full Changelog](https://github.com/acrmp/foodcritic/compare/v0.4.0...v0.5.0)

## [v0.4.0](https://github.com/acrmp/foodcritic/tree/v0.4.0) (2011-12-10)
[Full Changelog](https://github.com/acrmp/foodcritic/compare/v0.3.0...v0.4.0)

**Merged pull requests:**

- typo fix [\#2](https://github.com/acrmp/foodcritic/pull/2) ([smith](https://github.com/smith))

## [v0.3.0](https://github.com/acrmp/foodcritic/tree/v0.3.0) (2011-12-04)
[Full Changelog](https://github.com/acrmp/foodcritic/compare/v0.2.0...v0.3.0)

## [v0.2.0](https://github.com/acrmp/foodcritic/tree/v0.2.0) (2011-12-01)
[Full Changelog](https://github.com/acrmp/foodcritic/compare/v0.1.0...v0.2.0)

## [v0.1.0](https://github.com/acrmp/foodcritic/tree/v0.1.0) (2011-11-30)


\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*