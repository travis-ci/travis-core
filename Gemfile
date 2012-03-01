source :rubygems

gemspec

gem 'travis-support',     :git => 'git://github.com/travis-ci/travis-support.git'
gem 'metriks',            :git => 'git://github.com/mattmatt/metriks.git', :ref => "source"

platform :mri do
  gem 'amq-client',       '>= 0.9.1'
  gem 'amqp',             '>= 0.9.2'
  gem 'pg',               '~> 0.13.2'
end

platform :jruby do
  gem 'jruby-openssl',    '~> 0.7.4'
  gem 'hot_bunnies',      '~> 1.3.3'
  gem 'activerecord-jdbcpostgresql-adapter', '1.2.2' # see https://github.com/bmabey/database_cleaner/pull/83
  gem 'activerecord-jdbc-adapter',           '1.2.2'
end

group :development do
  gem 'standalone_migrations', '~> 1.0.5'
end

group :test do
  gem 'rspec',            '~> 2.8.0'
  gem 'factory_girl',     '~> 2.6.0'
  gem 'database_cleaner', '~> 0.7.1'
  gem 'mocha',            '~> 0.10.0'
  gem 'webmock',          '~> 1.8.0'
end
