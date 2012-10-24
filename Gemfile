source :rubygems

gemspec

gem 'travis-support',     github: 'travis-ci/travis-support'
gem 'gh',                 github: 'rkh/gh'
gem 'newrelic_rpm',       '~> 3.4.2'
gem 'hubble',             github: 'roidrage/hubble'
gem 'addressable'

platform :mri do
  gem 'bunny',            '~> 0.7.9'
  gem 'pg',               '~> 0.14.0'
end

platform :jruby do
  gem 'jruby-openssl',    '~> 0.7.7'
  gem 'hot_bunnies',      '~> 1.4.0.pre2'
  gem 'activerecord-jdbcpostgresql-adapter', '1.2.2' # see https://github.com/bmabey/database_cleaner/pull/83
  gem 'activerecord-jdbc-adapter',           '1.2.2'
end

group :development, :test do
  gem 'micro_migrations', git: 'git://gist.github.com/2087829.git'
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
end
