source 'https://rubygems.org'

gemspec

gem 'travis-support',     github: 'travis-ci/travis-support'
gem 'travis-sidekiqs',    github: 'travis-ci/travis-sidekiqs', require: nil
gem 'gh',                 github: 'travis-ci/gh'
gem 'addressable'
gem 'aws-sdk-v1'
gem 'json', '~> 1.8.2'

gem 'dalli'
gem 'connection_pool'
gem 'keen', '~> 0.8.6'

platform :mri do
  gem 'bunny',            '~> 0.7.9'
  gem 'pg',               '~> 0.18.2'
end

platform :jruby do
  gem 'jruby-openssl',    '~> 0.8.5'
  gem 'march_hare',       '~> 2.0.0'
  gem 'activerecord-jdbcpostgresql-adapter'
  gem 'activerecord-jdbc-adapter'
end

group :development, :test do
  gem 'micro_migrations'
end

group :test do
  gem 'rspec',            '~> 2.8.0'
  gem 'factory_girl',     '~> 2.6.0'
  gem 'database_cleaner', '~> 0.8.0'
  gem 'mocha',            '~> 0.10.0'
  gem 'webmock',          '~> 1.8.0'
  gem 'guard'
  gem 'guard-rspec'
  gem 'rb-fsevent'
  gem 'simplecov', require: false
end
