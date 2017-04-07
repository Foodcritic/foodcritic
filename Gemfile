source "https://rubygems.org"

gemspec

group :test do
  gem "aruba", "~> 0.5"
  gem "cucumber", ">= 2"
  gem "minitest", "~> 5.3"
  gem "minitest-reporters"
  gem "simplecov", "~> 0.8"
  gem "chefstyle", "~> 0.5"
end

group :development do
  gem "ronn", "~> 0.7"
  gem "pry"
end

group :changelog do
  # This fork has many fixes we want to use. Once this gets merged upstream we can use the gem again
  gem "github_changelog_generator", git: "https://github.com/tduffield/github-changelog-generator", branch: "adjust-tag-section-mapping"
end
