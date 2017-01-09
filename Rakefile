require "foodcritic/version"
require "bundler"
require "rake/testtask"

task :default => [:man, :install, :rubocop, :test, :features]

Bundler.setup
Bundler::GemHelper.install_tasks

Rake::TestTask.new do |t|
  t.pattern = "spec/foodcritic/*_spec.rb"
end

Rake::TestTask.new do |t|
  t.name = "regressions"
  t.pattern = "spec/regression/*_spec.rb"
end

begin
  require "cucumber"
  require "cucumber/rake/task"
  Cucumber::Rake::Task.new(:features) do |t|
    t.cucumber_opts = ["-f", "progress", "--strict"]
    unless ENV.has_key?("FC_FORK_PROCESS") && ENV["FC_FORK_PROCESS"] == true.to_s
      t.cucumber_opts += ["-t", "~@build"]
      t.cucumber_opts += ["-t", "~@context"]
    end
    t.cucumber_opts += ["features"]
  end
rescue LoadError
  puts "cucumber is not available. gem install cucumber to get rake rubocop to work"
end

begin
  require "chefstyle"
  require "rubocop/rake_task"
  desc "Run Chefstyle (rubocop)"
  RuboCop::RakeTask.new do |task|
    task.options << "--display-cop-names"
  end
rescue LoadError
  puts "chefstyle gem is not available. gem install chefstyle to get rake rubocop to work"
end

begin
  require "github_changelog_generator/task"

  GitHubChangelogGenerator::RakeTask.new :changelog do |config|
    config.header = "# FoodCritic Changelog:"
    config.future_release = FoodCritic::VERSION
    config.add_issues_wo_labels = false
    config.enhancement_labels = "enhancement,Enhancement,Enhancements,New Feature,Feature".split(",")
    config.bug_labels = "bug,Bug,Improvement,Upstream Bug".split(",")
    config.exclude_labels = "duplicate,question,invalid,wontfix,no_changelog,Exclude From Changelog,Question,Discussion,Tech Cleanup".split(",")
  end
rescue LoadError
  puts "github_changelog_generator is not available. gem install github_changelog_generator to generate changelogs"
end

desc "Build the manpage"
task(:man) do
  sh "ronn -w --roff man/*.ronn"
end
