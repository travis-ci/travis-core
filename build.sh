#!/bin/bash
RAILS_ENV=test bundle exec rake "$@"
export tresult=$?
find . -name hs_err_pid*.log -exec cat {} \;
exit $tresult
