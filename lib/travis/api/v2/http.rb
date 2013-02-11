module Travis
  module Api
    module V2
      module Http
        autoload :Accounts,     'travis/api/v2/http/accounts'
        autoload :Broadcasts,   'travis/api/v2/http/broadcasts'
        autoload :Branches,     'travis/api/v2/http/branches'
        autoload :Build,        'travis/api/v2/http/build'
        autoload :Builds,       'travis/api/v2/http/builds'
        autoload :Events,       'travis/api/v2/http/events'
        autoload :Hooks,        'travis/api/v2/http/hooks'
        autoload :Job,          'travis/api/v2/http/job'
        autoload :Jobs,         'travis/api/v2/http/jobs'
        autoload :Log,          'travis/api/v2/http/log'
        autoload :Permissions,  'travis/api/v2/http/permissions'
        autoload :Repositories, 'travis/api/v2/http/repositories'
        autoload :Repository,   'travis/api/v2/http/repository'
        autoload :SslKey,       'travis/api/v2/http/ssl_key'
        autoload :User,         'travis/api/v2/http/user'
        autoload :Workers,      'travis/api/v2/http/workers'
        autoload :Worker,       'travis/api/v2/http/worker'
      end
    end
  end
end
