require 'rubygems'
require 'bundler'
require 'cucumber'
require 'cucumber/rake/task'
require 'yard'
task :default => [:install, :features]

Bundler.setup
Bundler::GemHelper.install_tasks

Cucumber::Rake::Task.new(:features)

YARD::Rake::YardocTask.new