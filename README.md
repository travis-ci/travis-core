# travis-core

[![Build Status](https://api.travis-ci.org/travis-ci/travis-core.png?branch=master)](https://travis-ci.org/travis-ci/travis-core)

Travis Core (or travis-core) contains a lot of shared code between the different Travis CI applications.

See the [README in lib/travis](lib/travis) for more information on the structure of the repository.

## Contributing

Travis Core requires PostgreSQL 9.3 or higher, as well as a recent version of Redis and RabbitMQ.

### Repository setup

1. Clone the repository: `git clone https://github.com/travis-ci/travis-core.git`
2. Install gem dependencies: `bundle install --binstubs --path=vendor/gems`
3. Set up the database: `bin/rake db:setup db:test:prepare`

### Running tests

To run the RSpec tests: `bin/rake`. Make sure PostgreSQL, Redis and RabbitMQ are running.

### Submitting patches

Please fork the repository and submit a pull request. For larger changes, please open a ticket on our [main issue tracker](https://github.com/travis-ci/travis-ci/issues) first.

