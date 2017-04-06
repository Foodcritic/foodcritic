require "bundler/setup"

require 'bundler/gem_tasks'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec, :tag) do |t, args|
  t.rspec_opts = [].tap do |a|
    a << '--color'
    a << "--format #{ENV['CI'] ? 'documentation' : 'Fuubar'}"
    a << '--backtrace' if ENV['DEBUG']
    a << "--seed #{ENV['SEED']}" if ENV['SEED']
    a << "--tag ~regression" unless ENV['CI'] || args[:tag] == 'regression'
    a << "--tag #{args[:tag]}" if args[:tag]
  end.join(' ')
end

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

require "chefstyle"
require "rubocop/rake_task"
desc "Run Chefstyle (rubocop)"
RuboCop::RakeTask.new do |task|
  task.options << "--display-cop-names"
end

begin
  require "github_changelog_generator/task"
  require_relative "../lib/foodcritic/version"

  GitHubChangelogGenerator::RakeTask.new :changelog do |config|
    config.header = "# Foodcritic Changelog:"
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

task :default => [:man, :test, :rubocop]

desc 'Run all tests'
task :test => [:spec, :features]
