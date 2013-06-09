lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
require 'foodcritic/version'
Gem::Specification.new do |s|
  s.name = 'foodcritic'
  s.version = FoodCritic::VERSION
  s.description = 'Lint tool for Opscode Chef cookbooks.'
  s.summary = "foodcritic-#{s.version}"
  s.authors = ['Andrew Crump']
  s.homepage = 'http://acrmp.github.com/foodcritic'
  s.license = 'MIT'
  s.executables << 'foodcritic'
  s.add_dependency('gherkin', '~> 2.11.7')
  s.add_dependency('nokogiri', '~> 1.5.4')
  s.add_dependency('treetop', '~> 1.4.10')
  s.add_dependency('yajl-ruby', '~> 1.1.0')
  s.add_dependency('erubis')
  s.files = Dir['chef_dsl_metadata/*.json'] + Dir['lib/**/*.rb']
  s.files += Dir['spec/**/*'] + Dir['features/**/*']
  s.files += Dir['*.md'] + Dir['LICENSE']
  s.required_ruby_version = '>= 1.9.2'
end
