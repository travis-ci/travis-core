GITHUB_PAYLOADS = {
  "private-repo" => %({
    "repository": {
      "url": "http://github.com/svenfuchs/gem-release",
      "name": "gem-release",
      "private":true,
      "owner": {
        "email": "svenfuchs@artweb-design.de",
        "name": "svenfuchs"
      }
    },
    "commits": [{
      "id":        "9854592",
      "message":   "Bump to 0.0.15",
      "timestamp": "2010-10-27 04:32:37",
      "committer": {
        "name":  "Sven Fuchs",
        "email": "svenfuchs@artweb-design.de"
      },
      "author": {
        "name":  "Christopher Floess",
        "email": "chris@flooose.de"
      }
    }],
    "ref": "refs/heads/master"
  }),

  "gem-release" => %({
    "repository": {
      "url": "http://github.com/svenfuchs/gem-release",
      "name": "gem-release",
      "description": "Release your gems with ease",
      "owner": {
        "email": "svenfuchs@artweb-design.de",
        "name": "svenfuchs"
      }
    },
    "commits": [{
      "id":        "9854592",
      "message":   "Bump to 0.0.15",
      "timestamp": "2010-10-27 04:32:37",
      "committer": {
        "name":  "Sven Fuchs",
        "email": "svenfuchs@artweb-design.de"
      },
      "author": {
        "name":  "Christopher Floess",
        "email": "chris@flooose.de"
      }
    }],
    "ref": "refs/heads/master",
    "compare": "https://github.com/svenfuchs/gem-release/compare/af674bd...9854592"
  }),

  "travis-core" => %({
    "repository": {
      "url": "http://github.com/travis-ci/travis-core",
      "name": "gem-release",
      "description": "description for travis-core",
      "organization": "travis-ci",
      "owner": {
        "email": "contact@travis-ci.org",
        "name": "travis-ci"
      }
    },
    "commits": [{
      "id":        "9854592",
      "message":   "Bump to 0.0.15",
      "timestamp": "2010-10-27 04:32:37",
      "committer": {
        "name":  "Sven Fuchs",
        "email": "svenfuchs@artweb-design.de"
      },
      "author": {
        "name":  "Josh Kalderimis",
        "email": "josh@email.org"
      }
    }],
    "ref": "refs/heads/master",
    "compare": "https://github.com/travis-ci/travis-core/compare/af674bd...9854592"
  }),

  "travis-core-no-commit" => %({
    "repository": {
      "url": "http://github.com/travis-ci/travis-core",
      "name": "gem-release",
      "description": "description for travis-core",
      "organization": "travis-ci",
      "owner": {
        "email": "contact@travis-ci.org",
        "name": "travis-ci"
      }
    },
    "commits":[],
    "ref": "refs/heads/master",
    "compare": "https://github.com/travis-ci/travis-core/compare/af674bd...9854592"
  }),

  "gh-pages-update" => %({
    "repository": {
      "url": "http://github.com/svenfuchs/gem-release",
      "name": "gem-release",
      "owner": {
        "email": "svenfuchs@artweb-design.de",
        "name": "svenfuchs"
      }
    },
    "commits": [{
      "id":        "9854592",
      "message":   "Bump to 0.0.15",
      "timestamp": "2010-10-27 04:32:37",
      "committer": {
        "name":  "Sven Fuchs",
        "email": "svenfuchs@artweb-design.de"
      },
      "author": {
        "name":  "Christopher Floess",
        "email": "chris@flooose.de"
      }
    }],
    "ref": "refs/heads/gh-pages"
  }),

  "gh_pages-update" => %({
    "repository": {
      "url": "http://github.com/svenfuchs/gem-release",
      "name": "gem-release",
      "owner": {
        "email": "svenfuchs@artweb-design.de",
        "name": "svenfuchs"
      }
    },
    "commits": [{
      "id":        "9854592",
      "message":   "Bump to 0.0.15",
      "timestamp": "2010-10-27 04:32:37",
      "committer": {
        "name":  "Sven Fuchs",
        "email": "svenfuchs@artweb-design.de"
      },
      "author": {
        "name":  "Christopher Floess",
        "email": "chris@flooose.de"
      }
    }],
    "ref": "refs/heads/gh_pages"
  }),

  # it is unclear why this payload was send but it happened quite often. the force option
  # seems to indicate something like $ git push --force
  "force-no-commit" => %({
    "pusher": { "name": "LTe", "email":"lite.88@gmail.com" },
    "repository":{
      "name":"acts-as-messageable",
      "created_at":"2010/08/02 07:41:30 -0700",
      "has_wiki":true,
      "size":200,
      "private":false,
      "watchers":13,
      "fork":false,
      "url":"https://github.com/LTe/acts-as-messageable",
      "language":"Ruby",
      "pushed_at":"2011/05/31 04:16:01 -0700",
      "open_issues":0,
      "has_downloads":true,
      "homepage":"http://github.com/LTe/acts-as-messageable",
      "has_issues":true,
      "forks":5,
      "description":"ActsAsMessageable",
      "owner": { "name":"LTe", "email":"lite.88@gmail.com" }
    },
    "ref_name":"v0.3.0",
    "forced":true,
    "after":"b842078c2f0084bb36cea76da3dad09129b3c26b",
    "deleted":false,
    "ref":"refs/tags/v0.3.0",
    "commits":[],
    "base_ref":"refs/heads/master",
    "before":"0000000000000000000000000000000000000000",
    "compare":"https://github.com/LTe/acts-as-messageable/compare/v0.3.0",
    "created":true
  }),

  :oauth => {
    "uid" => "234423",
    "info" => {
      "name" => "John",
      "nickname" => "john",
      "email" => "john@email.com"
    },
    "credentials" => {
      "token" => "1234567890abcdefg"
    },
    "extra" => {
      "raw_info" => {
        "gravatar_id" => "41193cdbffbf06be0cdf231b28c54b18"
      }
    }
  },
}

GITHUB_OAUTH_DATA = {
  'name'               => 'John',
  'email'              => 'john@email.com',
  'login'              => 'john',
  'github_id'          => 234423,
  'github_oauth_token' => '1234567890abcdefg',
  'gravatar_id'        => '41193cdbffbf06be0cdf231b28c54b18'
}

WORKER_PAYLOADS = {
  'job:configure:started'  => { 'id' => 1, 'state' => 'started',  'started_at'  => '2011-01-01 00:00:00 +0200' },
  'job:configure:finished' => { 'id' => 1, 'state' => 'finished', 'finished_at' => '2011-01-01 00:01:00 +0200', 'config' => { 'rvm' => ['1.8.7', '1.9.2'] } },
  'job:test:started'       => { 'id' => 1, 'state' => 'started',  'started_at'  => '2011-01-01 00:02:00 +0200', 'worker' => 'ruby3.worker.travis-ci.org:travis-ruby-4' },
  'job:test:log'           => { 'id' => 1, 'log' => '... appended' },
  'job:test:log:1'         => { 'id' => 1, 'log' => 'the '  },
  'job:test:log:2'         => { 'id' => 1, 'log' => 'full ' },
  'job:test:log:3'         => { 'id' => 1, 'log' => 'log'   },
  'job:test:finished'      => { 'id' => 1, 'state' => 'finished', 'finished_at' => '2011-01-01 00:03:00 +0200', 'status' => 0, 'log' => 'the full log' }
}

QUEUE_PAYLOADS = {
  'job:configure' => {
    :build      => { :id => 1, :commit => '9854592', :branch => 'master' },
    :repository => { :id => 1, :slug => 'svenfuchs/gem-release' },
    :queue      => 'builds.common'
  },
  'job:test:1' => {
    :build      => { :id => 2, :number => '1.1', :commit => '9854592', :branch => 'master', :config => { :rvm => '1.8.7' } },
    :repository => { :id => 1, :slug => 'svenfuchs/gem-release' },
    :queue      => 'builds.common'
  },
  'job:test:2' => {
    :build      => { :id => 3, :number => '1.2', :commit => '9854592', :branch => 'master', :config => { :rvm => '1.9.2' } },
    :repository => { :id => 1, :slug => 'svenfuchs/gem-release' },
    :queue      => 'builds.common'
  }
}
