#!/bin/bash
RAILS_ENV=test bundle exec rspec "$@"
export tresult=$?
find . -name hs_err_pid*.log -exec cat {} \;
exit $tresult
