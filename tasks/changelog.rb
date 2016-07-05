begin
  require "github_changelog_generator/task"

  GitHubChangelogGenerator::RakeTask.new :changelog do |config|
    config.header = "# FoodCritic Changelog:"
    config.future_release = FoodCritic::VERSION
    config.enhancement_labels = "enhancement,Enhancement,Enhancements,New Feature,Feature".split(",")
    config.bug_labels = "bug,Bug,Improvement,Upstream Bug".split(",")
    config.exclude_labels = "duplicate,question,invalid,wontfix,no_changelog,Exclude From Changelog,Question,Discussion".split(",")
    #config.issues = false
  end
rescue LoadError
  puts "github_changelog_generator is not available. gem install github_changelog_generator to generate changelogs"
end
