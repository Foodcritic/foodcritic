lib = File.expand_path("../lib/", __FILE__)
$:.unshift lib unless $:.include?(lib)
require "foodcritic/version"
Gem::Specification.new do |s|
  s.name = "foodcritic"
  s.version = FoodCritic::VERSION
  s.description = "A code linting tool for Chef Infra cookbooks."
  s.summary = "foodcritic-#{s.version}"
  s.authors = ["Andrew Crump"]
  s.homepage = "http://foodcritic.io"
  s.license = "MIT"
  s.executables << "foodcritic"
  s.required_ruby_version = ">= 2.3"

  s.files = Dir["chef_dsl_metadata/*.json"] +
    Dir["lib/**/*.rb"] +
    Dir["misc/**/*"]
  s.files += Dir["Gemfile", "foodcritic.gemspec", "LICENSE"]

  s.add_dependency("nokogiri", ">= 1.5", "< 2.0")
  s.add_dependency("rake")
  s.add_dependency("treetop", "~> 1.4")
  s.add_dependency("ffi-yajl", "~> 2.0")
  s.add_dependency("erubis")
  s.add_dependency("rufus-lru", "~> 1.0")

  s.add_development_dependency "cucumber-core", ">= 1.3", "< 4.0"
  s.add_development_dependency "rspec", "~> 3.5"
  s.add_development_dependency "fuubar", "~> 2.0"
  s.add_development_dependency "rspec-command", "~> 1.0"
end
