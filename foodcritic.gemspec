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
  s.add_dependency('chef', '~> 0.10.4')
  s.add_dependency("json", ">= 1.4.4", "<= 1.6.1")
  s.add_dependency('gherkin', '~> 2.8.0')
  s.add_dependency('gist', '~> 2.0.4')
  s.add_dependency('nokogiri', '~> 1.5.0')
  s.add_dependency('pry', '~> 0.9.7.4')
  s.add_dependency('pry-doc', '~> 0.3.0')
  s.add_dependency('rak', '~> 1.4')
  s.add_dependency('treetop', '~> 1.4.10')
  s.add_dependency('yajl-ruby', '~> 1.0.0')
  s.files = Dir['lib/**/*.rb'] + Dir['*.json']
  s.required_ruby_version = '>= 1.9.2'
end
