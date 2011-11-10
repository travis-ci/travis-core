source :rubygems

gemspec

platform :mri do
  gem 'amqp',              '~> 0.8.2'
  gem 'pg',                '~> 0.11.0'
  gem 'silent-postgres',   '~> 0.0.8'
end

platform :jruby do
  gem 'jruby-openssl'
  gem 'hot_bunnies',       '~> 1.2.2'
  gem 'activerecord-jdbcpostgresql-adapter'
end

group :development do
  gem 'standalone_migrations'
end

group :test do
  gem 'rspec',             '~> 2.7.0'
  gem 'factory_girl',      '~> 2.1.2'
  gem 'database_cleaner',  '~> 0.6.7'
  gem 'mocha',             '~> 0.10.0'
  gem 'webmock',           '~> 1.7.7'
end
