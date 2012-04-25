# travis-core



## Testing
### Prerequisites
* PostgreSQL
* Redis
 
### Initial Setup
```  
$ git clone git://github.com/travis-ci/travis-core.git
$ cd travis-core
$ bundle install
```
In Postgres:
```
CREATE USER postgres;
create database travis_test;
```

```
$ RAILS_ENV=test bundle exec rake db:migrate
```

### Running the tests
```
$ bundle exec rake
```