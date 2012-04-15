require 'travis/testing/webmock'

Support::Webmock.urls = %w(
  https://api.github.com/users/svenfuchs/repos?per_page=9999
  https://api.github.com/users/svenfuchs
  https://api.github.com/users/LTe
  https://api.github.com/orgs/travis-ci
  https://github.com/api/v2/json/repos/show/svenfuchs
  http://github.com/api/v2/json/repos/show/svenfuchs/gem-release
  http://github.com/api/v2/json/repos/show/svenfuchs/minimal
  http://github.com/api/v2/json/repos/show/travis-ci/travis-ci
  http://github.com/api/v2/json/user/show/svenfuchs
  http://github.com/api/v2/json/organizations/travis-ci/public_members
  http://github.com/api/v2/json/user/show/LTe
  https://api.github.com/users/travis-repos
  https://api.github.com/orgs/travis-repos
  https://api.github.com/repos/travis-repos/test-project-1/git/refs/pull/1/merge
  https://api.github.com/repos/travis-repos/test-project-1/git/commits/e99a0a08d2e6c9818d4cf0bb28af81be2cd06fd2
  https://api.github.com/users/travis-ci
  https://api.github.com/repos/travis-repos/test-project-1
  https://api.github.com/repos/travis-repos/test-project-1/pulls/1
  https://api.github.com/repos/travis-repos/test-project-1/git/refs/pull/1
  https://api.github.com/repos/travis-repos/test-project-1/git/commits/9b00989b1a0e7d9b609ad2e28338c060f79a71ac
  https://github.com/travis-repos/test-project-1/pull/1/mergeable
)
