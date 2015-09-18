lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
require 'foodcritic/version'
Gem::Specification.new do |s|
  s.name = 'foodcritic'
  s.version = FoodCritic::VERSION
  s.description = 'Lint tool for Chef cookbooks.'
  s.summary = "foodcritic-#{s.version}"
  s.authors = ['Andrew Crump']
  s.homepage = 'http://foodcritic.io'
  s.license = 'MIT'
  s.executables << 'foodcritic'
  s.required_ruby_version = ">= 2.0.0"
  s.add_dependency('gherkin', '~> 2.11')
  s.add_dependency('nokogiri', '>= 1.5', '< 2.0')
  s.add_dependency('rake')
  s.add_dependency('treetop', '~> 1.4')
  s.add_dependency('yajl-ruby', '~> 1.1')
  s.add_dependency('erubis')
  s.add_dependency('rufus-lru', '~> 1.0')
  s.files = Dir['chef_dsl_metadata/*.json'] +
    Dir['lib/**/*.rb'] +
    Dir['misc/**/*']
  s.files += Dir['spec/**/*'] + Dir['features/**/*']
  s.files += Dir['*.md'] + Dir['LICENSE'] + Dir['man/*']
  s.required_ruby_version = '>= 2.0.0'
end
