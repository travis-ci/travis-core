# travis-core

[![Build Status](https://api.travis-ci.org/travis-ci/travis-core.png?branch=master)](https://travis-ci.org/travis-ci/travis-core)

Travis Core (or travis-core) contains shared code among different Travis CI applications.

See the [README in lib/travis](lib/travis) for more information on the structure of the repository.

## Contributing

Travis Core requires PostgreSQL 9.3 or higher, as well as a recent version of Redis and RabbitMQ.

### Repository setup

1. Clone the repository: `git clone https://github.com/travis-ci/travis-core.git`
1. Install gem dependencies: `cd travis-core; bundle install --binstubs --path=vendor/gems`

### Database setup

NB detail for how `rake` sets up the database can be found in the `Rakefile`. In the `namespace :db` block you will see the database name is configured using the environment variable RAILS_ENV. If you are using a different configuration you will have to make your own adjustments.

1. `bundle exec rake db:create`
2. for testing, you will need to run `RAILS_ENV=test bundle exec rake db:create --trace`


### Running tests

To run the RSpec tests, first make sure PostgreSQL, Redis and
RabbitMQ are running, then do:

```
./build.sh
```

Individual specs can be run with `bin/rspec`; e.g.,

```
bundle exec rspec spec/travis/model/job_spec.rb
```

### Submitting patches

Please fork the repository and submit a pull request. For larger changes, please open a ticket on our [main issue tracker](https://github.com/travis-ci/travis-ci/issues) first.
