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
  s.add_dependency('nokogiri', '~> 1.5.0')
  s.files = Dir['lib/**/*.rb']
  s.required_ruby_version = '>= 1.9.3'
end
