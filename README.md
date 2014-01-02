# travis-core

## Testing
### Prerequisites
* PostgreSQL  >= 9.2
* Redis       >= 2.4

### Initial Setup
```
$ git clone git://github.com/travis-ci/travis-core.git
$ cd travis-core
$ bundle install
$ bundle exec rake db:setup
$ bundle exec rake db:test:prepare

```

### Running the tests
```
$ bundle exec rake
```

## Code Status

  * [![Build Status](https://api.travis-ci.org/travis-ci/travis-core.png)](https://travis-ci.org/travis-ci/travis-core)
