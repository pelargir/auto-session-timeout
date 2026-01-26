source 'https://rubygems.org'

rails_version = ENV['RAILS_VERSION']
gem 'actionpack', rails_version

# Ruby 3.4+ removed these from stdlib, but older Rails versions need them
if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('3.4.0')
  gem 'mutex_m'
  gem 'bigdecimal'
end

# Specify your gem's dependencies in auto-session-timeout.gemspec
gemspec
