source :rubygems

gemspec

platform :mri do
  gem 'amqp',              '~> 0.8.3'
  gem 'pg',                '~> 0.11.0'
  gem 'silent-postgres',   '~> 0.0.8'
end

platform :jruby do
  gem 'jruby-openssl',     '~> 0.7.4'
  gem 'hot_bunnies',       '~> 1.3.3'
  gem 'activerecord-jdbcpostgresql-adapter', '~> 1.2.0'
end

group :development do
  gem 'standalone_migrations', '~> 1.0.5'
end

group :test do
  gem 'rspec',             '~> 2.7.0'
  gem 'factory_girl',      '~> 2.1.2'
  gem 'database_cleaner',  '~> 0.6.7'
  gem 'mocha',             '~> 0.10.0'
  gem 'webmock',           '~> 1.7.7'
end
