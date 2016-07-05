require "foodcritic/version"
require 'bundler'
require 'rake/testtask'
require_relative "tasks/changelog"

task :default => [:man, :install, :test, :features]

Bundler.setup
Bundler::GemHelper.install_tasks

Rake::TestTask.new do |t|
  t.pattern = 'spec/foodcritic/*_spec.rb'
end

Rake::TestTask.new do |t|
  t.name = 'regressions'
  t.pattern = 'spec/regression/*_spec.rb'
end

begin
  require 'cucumber'
  require 'cucumber/rake/task'
  Cucumber::Rake::Task.new(:features) do |t|
    t.cucumber_opts = ['-f', 'progress', '--strict']
    unless ENV.has_key?('FC_FORK_PROCESS') and ENV['FC_FORK_PROCESS'] == true.to_s
      t.cucumber_opts += ['-t', '~@build']
      t.cucumber_opts += ['-t', '~@context']
    end
    t.cucumber_opts += ['features']
  end
rescue LoadError
  puts "cucumber is not available. gem install cucumber to get rake rubocop to work"
end

begin
  require 'rubocop/rake_task'
  desc 'Run RuboCop'
  RuboCop::RakeTask.new(:rubocop) do |task|
    task.patterns = ['bin/*']
    task.patterns = ['lib/**/*.rb']
  end
rescue LoadError
  puts "rubocop is not available. gem install rubocop to get rake rubocop to work"
end

desc 'Build the manpage'
task(:man) do
  sh 'ronn -w --roff man/*.ronn'
end
