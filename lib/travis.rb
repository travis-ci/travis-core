require 'travis/support'
require 'travis/exceptions'

autoload :Artifact,     'travis/model/artifact'
autoload :Build,        'travis/model/build'
autoload :Commit,       'travis/model/commit'
autoload :Job,          'travis/model/job'
autoload :Membership,   'travis/model/membership'
autoload :Organization, 'travis/model/organization'
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
# travis/model         - contains ActiveRecord models that and model the main
#                        parts of the domain logic (e.g. repository, build, job
#                        etc.) and issue events on state changes (e.g.
#                        build:created, job:test:finished etc.)
# travis/notifications - contains event handlers that register for certain
#                        events and send out such things as email, pusher, irc
#                        notifications, archive builds or queue jobs for the
#                        workers.
# travis/mailer        - contains ActionMailers for sending out email
#                        notifications
# travis/views         - contains Rabl views for creating JSON payloads used
#                        for pusher and webhook notifications, build archiving
#                        and worker job payloads. (TODO This should be replaced
#                        with some saner sort of JSON generation, like, just
#                        plain Ruby?)
#
# travis-core also contains some helper classes and modules like Travis::Database
# (needed in travis-hub in order to connect to the database) and Travis::Renderer
# (our inferior layer on top of Rabl).
module Travis
  autoload :Api,           'travis/api'
  autoload :Config,        'travis/config'
  autoload :Database,      'travis/database'
  autoload :EventLogger,   'travis/event_logger'
  autoload :Features,      'travis/features'
  autoload :Github,        'travis/github'
  autoload :Mailer,        'travis/mailer'
  autoload :Model,         'travis/model'
  autoload :Notifications, 'travis/notifications'
  autoload :Renderer,      'travis/renderer'

  class << self
    def config
      @config ||= Config.new
    end

    def pusher
      @pusher ||= ::Pusher.tap do |pusher|
        pusher.app_id = config.pusher.app_id
        pusher.key    = config.pusher.key
        pusher.secret = config.pusher.secret
      end
    end
  end
end
