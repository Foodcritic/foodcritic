require "bundler/setup"
require "mixlib/shellout"

require "bundler/gem_tasks"

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:spec, :tag) do |t, args|
  t.rspec_opts = [].tap do |a|
    a << "--color"
    a << "--format #{ENV['CI'] ? 'documentation' : 'Fuubar'}"
    a << "--backtrace" if ENV["DEBUG"]
    a << "--seed #{ENV['SEED']}" if ENV["SEED"]
    a << "--tag ~regression" unless ENV["CI"] || args[:tag] == "regression"
    a << "--tag #{args[:tag]}" if args[:tag]
  end.join(" ")
end

require "cucumber"
require "cucumber/rake/task"
Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = %w{--strict}
  t.cucumber_opts += %w{-f progress} unless ENV["CI"]
  unless ENV.has_key?("FC_FORK_PROCESS") && ENV["FC_FORK_PROCESS"] == "true"
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

desc "Run all tests"
task :test => [:spec, :features]

desc "Regenerate regression test data"
task :regen_regression do
  in_path = File.expand_path("../spec/regression/cookbooks.txt", __FILE__)
  cookbooks = IO.readlines(in_path)
  cookbooks.each_with_index do |line, i|
    name, ref = line.strip.split(":")
    puts "Regenerating output for #{name} (#{i + 1}/#{cookbooks.size})"
    Dir.mktmpdir do |temp|
      clone_cmd = Mixlib::ShellOut.new("git", "clone", "https://github.com/chef-cookbooks/#{name}.git", ".", cwd: temp)
      clone_cmd.run_command
      clone_cmd.error!
      checkout_cmd = Mixlib::ShellOut.new("git", "checkout", ref, cwd: temp)
      checkout_cmd.run_command
      checkout_cmd.error!
      fc_cmd = Mixlib::ShellOut.new(File.expand_path("../bin/foodcritic", __FILE__), "--no-progress", ".", cwd: temp)
      fc_cmd.run_command
      out_path = File.expand_path("../spec/regression/expected/#{name}.txt", __FILE__)
      IO.write(out_path, fc_cmd.stdout)
    end
  end
end
