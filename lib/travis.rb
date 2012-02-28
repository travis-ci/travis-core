require 'travis/support'

autoload :Artifact,    'travis/model/artifact'
autoload :Build,       'travis/model/build'
autoload :Commit,      'travis/model/commit'
autoload :Job,         'travis/model/job'
autoload :Repository,  'travis/model/repository'
autoload :Request,     'travis/model/request'
autoload :ServiceHook, 'travis/model/service_hook'
autoload :SslKey,      'travis/model/ssl_key'
autoload :Token,       'travis/model/token'
autoload :User,        'travis/model/user'
autoload :Worker,      'travis/model/worker'

module Travis
  autoload :Config,        'travis/config'
  autoload :Database,      'travis/database'
  autoload :EventLogger,   'travis/event_logger'
  autoload :GithubApi,     'travis/github_api'
  autoload :Mailer,        'travis/mailer'
  autoload :Model,         'travis/model'
  autoload :Notifications, 'travis/notifications'
  autoload :Renderer,      'travis/renderer'

  class << self
    attr_accessor :pusher

    def config
      @config ||= Config.new
    end
  end
end
