source 'https://rubygems.org'

gemspec

gem 'travis-support',     github: 'travis-ci/travis-support'
gem 'travis-sidekiqs',    github: 'travis-ci/travis-sidekiqs', require: nil
gem 'gh',                 github: 'rkh/gh'
gem 'newrelic_rpm',       '~> 3.4.2'
gem 'hubble',             github: 'roidrage/hubble'
gem 'addressable'
gem 'aws-sdk'
gem 'json', '~> 1.7.7'

# TODO need to release the gem as soon i'm certain this change makes sense
gem 'simple_states', github: 'svenfuchs/simple_states', branch: 'sf-set-state-early'

platform :mri do
  gem 'bunny',            '~> 0.7.9'
  gem 'pg',               '~> 0.14.0'
end

platform :jruby do
  gem 'jruby-openssl',    '~> 0.8.5'
  gem 'hot_bunnies',      '~> 1.4.0.pre2'
  gem 'activerecord-jdbcpostgresql-adapter', '1.2.2.1' # see https://github.com/bmabey/database_cleaner/pull/83
  gem 'activerecord-jdbc-adapter',           '1.2.2.1'
end

group :development, :test do
  gem 'micro_migrations', git: 'https://gist.github.com/2087829.git'
  gem 'data_migrations',  '~> 0.0.1'
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
end
