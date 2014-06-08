# travis-core

[![Build Status](https://api.travis-ci.org/travis-ci/travis-core.png?branch=master)](https://travis-ci.org/travis-ci/travis-core)

Travis Core (or travis-core) contains shared code among different Travis CI applications.

See the [README in lib/travis](lib/travis) for more information on the structure of the repository.

## Contributing

Travis Core requires PostgreSQL 9.3 or higher, as well as a recent version of Redis and RabbitMQ.

### Repository setup

1. Clone the repository: `git clone https://github.com/travis-ci/travis-core.git`
1. Install gem dependencies: `cd travis-core; bundle install --binstubs --path=vendor/gems`
1. Set up the database: `bin/rake db:create db:structure:load`
1. Clone `travis-logs` and copy the `logs` database (assume the PostgreSQL user is `postgres`):
```sh-session
cd ..
git clone https://github.com/travis-ci/travis-logs.git
cd travis-logs
rvm jruby do bundle exec rake db:migrate # `travis-logs` requires JRuby
psql -c "DROP TABLE IF EXISTS logs CASCADE" -U postgres travis_development
pg_dump -t logs travis_logs_development | psql -U postgres travis_development
```

Repeat the database steps for `RAILS_ENV=test`.
```sh-session
RAILS_ENV=test bin/rake db:create db:structure:load
pushd ../travis-logs
RAILS_ENV=test rvm jruby do bundle exec rake db:migrate
psql -c "DROP TABLE IF EXISTS logs CASCADE" -U postgres travis_test
pg_dump -t logs travis_logs_test | psql -U postgres travis_test
popd
```

### Running tests

To run the RSpec tests: `bin/rake`. Make sure PostgreSQL, Redis and RabbitMQ are running.

Individual specs can be run with `bin/rspec`; e.g.,

```
bin/rspec spec/travis/model/job_spec.rb
```

### Submitting patches

Please fork the repository and submit a pull request. For larger changes, please open a ticket on our [main issue tracker](https://github.com/travis-ci/travis-ci/issues) first.

