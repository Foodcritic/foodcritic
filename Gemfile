source 'https://rubygems.org'

gem 'foodcritic', :path => '.'

group :test do
  gem 'aruba', '~> 0.5'
  gem 'cucumber', '~> 1.3'
  gem 'minitest', '~> 5.3'
  gem 'simplecov', '~> 0.8'
end

group :development do
  gem 'chef', '~> 12.1.1'
  gem 'ronn', '~> 0.7'

  # We need to lock mustache because ronn does not correctly
  # specify its dependency on mustache. mustache >= 1.0 requires
  # ruby >= 2, and we still want 1.9.3 here.
  gem 'mustache', '~> 0.99'

  gem 'rubocop', '~> 0.20', require: false
end
