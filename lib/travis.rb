require 'travis/support'
require 'travis_core/version'
require 'gh'
require 'pusher'
require 'travis/redis_pool'
require 'travis/errors'

# travis-core holds the central parts of the model layer used in both travis-ci
# (i.e. the web application) as well as travis-hub (a non-rails ui-less JRuby
# application that receives, processes and distributes messages from/to the
# workers and issues various events like email, pusher, irc notifications and
# so on).
#
# travis/model   - contains ActiveRecord models that and model the main
#                  parts of the domain logic (e.g. repository, build, job
#                  etc.) and issue events on state changes (e.g.
#                  build:created, job:test:finished etc.)
# travis/event   - contains event handlers that register for certain
#                  events and send out such things as email, pusher, irc
#                  notifications, archive builds or queue jobs for the
#                  workers.
# travis/mailer  - contains ActionMailers for sending out email
#                  notifications
#
# travis-core also contains some helper classes and modules like Travis::Database
# (needed in travis-hub in order to connect to the database) and Travis::Renderer
# (our inferior layer on top of Rabl).
module Travis
  class << self
    def services=(services)
      # Travis.logger.info("Using services: #{services}")
      @services = services
    end

    def services
      @services ||= Travis::Services
    end
  end

  require 'travis/task'
  require 'travis/event'
  require 'travis/addons'
  require 'travis/api'
  require 'travis/config'
  require 'travis/commit_command'
  require 'travis/features'
  require 'travis/services'
  require 'travis/enqueue'
  require 'travis/requests'
  require 'travis/github'
  require 'travis/mailer'
  require 'travis/notification'

  class UnknownRepository < StandardError; end
  class GithubApiError    < StandardError; end
  class AdminMissing      < StandardError; end
  class RepositoryMissing < StandardError; end
  class LogAlreadyRemoved < StandardError; end
  class AuthorizationDenied < StandardError; end
  class JobUnfinished     < StandardError; end

  class << self
    def setup
      Travis.logger.info('Setting up Travis::Core')

      GH.set(
        client_id:      Travis.config.oauth2.try(:client_id),
        client_secret:  Travis.config.oauth2.try(:client_secret),
        user_agent:     "Travis-CI/#{TravisCore::VERSION} GH/#{GH::VERSION}",
        origin:         Travis.config.host
      )

      Addons.register
      Services.register
      Enqueue::Services.register
      Github::Services.register
      Requests::Services.register
    end

    attr_accessor :redis

    def start
      @redis = Travis::RedisPool.new(config.redis)
    end

    def config
      @config ||= Config.new
    end

    def pusher
      @pusher ||= ::Pusher.tap do |pusher|
        pusher.app_id = config.pusher.app_id
        pusher.key    = config.pusher.key
        pusher.secret = config.pusher.secret
        pusher.scheme = config.pusher.scheme if config.pusher.scheme.present?
        pusher.host   = config.pusher.host   if config.pusher.host.present?
        pusher.port   = config.pusher.port   if config.pusher.port.present?
      end
    end

    def states_cache
      @states_cache ||= Travis::StatesCache.new
    end
  end

  setup
  start
end
