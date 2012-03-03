require 'rubygems'
require 'bundler'
require 'rake/testtask'
require 'cucumber'
require 'cucumber/rake/task'
require 'yard'
task :default => ['chef_dsl_metadata.json', :install, :test, :features]

Bundler.setup
Bundler::GemHelper.install_tasks

Rake::TestTask.new do |t|
  t.pattern = 'spec/**/*_spec.rb'
end

Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = ['-f', 'progress']
  if ENV.has_key?('FC_FORK_PROCESS') and ENV['FC_FORK_PROCESS'] == true.to_s
    t.cucumber_opts += ['-t', '~@repl', 'features']
  end
end

YARD::Rake::YardocTask.new
