require 'travis/support'
require 'gh'
require 'pusher'

autoload :Account,      'travis/model/account'
autoload :Artifact,     'travis/model/artifact'
autoload :Broadcast,    'travis/model/broadcast'
autoload :Build,        'travis/model/build'
autoload :Commit,       'travis/model/commit'
autoload :Event,        'travis/model/event'
autoload :Job,          'travis/model/job'
autoload :Membership,   'travis/model/membership'
autoload :Organization, 'travis/model/organization'
autoload :Permission,   'travis/model/permission'
autoload :Repository,   'travis/model/repository'
autoload :Request,      'travis/model/request'
autoload :ServiceHook,  'travis/model/service_hook'
autoload :SslKey,       'travis/model/ssl_key'
autoload :Token,        'travis/model/token'
autoload :User,         'travis/model/user'
autoload :Url,          'travis/model/url'
autoload :Worker,       'travis/model/worker'

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
  autoload :Addons,       'travis/addons'
  autoload :Api,          'travis/api'
  autoload :Config,       'travis/config'
  autoload :Event,        'travis/event'
  autoload :Features,     'travis/features'
  autoload :Mailer,       'travis/mailer'
  autoload :Model,        'travis/model'
  autoload :Notification, 'travis/notification'
  autoload :Services,     'travis/services'
  autoload :Task,         'travis/task'
  autoload :Testing,      'travis/testing'

  extend Services

  class UnknownRepository < StandardError; end
  class GithubApiError < StandardError; end
  class AdminMissing < StandardError; end

  class << self
    attr_writer :services

    def config
      @config ||= Config.new
    end

    # TODO check with @rkh where this is actually required
    def setup(config = Travis.config.oauth2)
      GH.set(:client_id => config[:client_id], :client_secret => config[:client_secret]) if config
    end

    def pusher
      @pusher ||= ::Pusher.tap do |pusher|
        pusher.app_id = config.pusher.app_id
        pusher.key    = config.pusher.key
        pusher.secret = config.pusher.secret
      end
    end

    def services
      @services || raise('no services namespace set')
    end
  end

  setup
end
