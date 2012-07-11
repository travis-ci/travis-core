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

## Metriks from travis-hub and travis-core

* `v1.travis.hub.handler.sync.handle`

  Responds to a `sync` request (which was issued by `travis-ci` on user/sign-in)

* `v1.travis.github.sync.organizations.run`

  Synchronizes all orgs for a given user.

* `v1.travis.github.sync.repositories.run`

  Synchronizes all repos for a given user.

* `v1.travis.github.repositories.fetch`

  Fetches all repositories for a given user from the Github API.

* `v1.travis.hub.handler.request.pull\_request.authenticate`

  Authenticates a `pull\_request` event from Github.

* `v1.travis.hub.handler.request.pull\_request.handle`

  Handles a `pull\_request` event from Github (which had been received and queued by `travis-listener`)

* `v1.travis.hub.handler.request.push.authenticate`

  Authenticates a `push` event from Github.

* `v1.travis.hub.handler.request.push.handle`

  Handles a `push` event from Github (which had been received and queued by `travis-listener`)

* `v1.request.factory.request`

  Creates a `Request` instance (domain model that is created in response to a Github `push` or `pull\_request` event)

* `v1.travis.github.config.fetch`

  Fetches the `.travis.yml` file from Github.

* `v1.travis.event.handler.\*.notify`

  Responds to `build:finished` events and creates an instance of `Task::Archive`.

* `v1.travis.hub.handler.job.[log|update]`

  Responds to events on the workers (i.e. reporting about the build process)

* `v1.travis.hub.handler.worker.handle`

  Responds to `worker:\*` events on workers (e.g. worker:added, worker:removed etc)

* `v1.travis.task.\*.run`

  Performs tasks sending out emails, pusher, irc notifications etc.

