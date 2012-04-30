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
$ bundle exec rake db:setup
$ bundle exec rake db:test:prepare

```

### Running the tests
```
$ bundle exec rake
```