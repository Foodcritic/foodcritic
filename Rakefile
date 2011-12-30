require 'rubygems'
require 'bundler'
require 'cucumber'
require 'cucumber/rake/task'
require 'yard'
task :default => [:install, :features]

Bundler.setup
Bundler::GemHelper.install_tasks

Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = ['-t', '~@repl', 'features'] if ENV.has_key?('FC_FORK_PROCESS') and ENV['FC_FORK_PROCESS'] == true.to_s
end

YARD::Rake::YardocTask.new