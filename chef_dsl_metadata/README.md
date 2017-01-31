# Generating metadata for a specific chef version

- run 'bundle install' to install appraisal
- update Appraisals file with new chef version(s)
- run 'bundle exec appraisal install'. It will fail, but it will still generate the Gemfile
- run 'bundle exec appraisal chef_12.8.1 rake generate_chef_metadata' to generate json for that version of chef

# Generating metadata for all version of Chef

- run 'bundle install' to install appraisal
- update Appraisals file with new chef version(s)
- run 'bundle exec appraisal' to generate the gemfiles for all the chef versions
- run 'bundle exec appraisal rake generate_chef_metadata' to generate the json for all the chef versions

## Notes

The Rakefile is not intended to be run directly without invoking appraisal to essentially bundle exec it against the correct gemfile.

Due to incompatibility between legacy Chef releases and modern Ruby releases, generating metadata for all versions of Chef will fail. You'll need generate metadata for specific releases, or comment out the older releases in the Appraisal file before generating metadata in bulk.
