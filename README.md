# travis-core

## Testing
This may not be entirely correct, but it's what I had to do:
* Clone project
* bundle install
* create postgres user to match mac user
* create database travis_test;
* RAILS_ENV=test bundle exec rake db:migrate
* Install and Run redis (stock configuration works fine)
* bundle exec rake