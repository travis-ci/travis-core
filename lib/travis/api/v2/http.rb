module Travis
  module Api
    module V2
      module Http
        autoload :Accounts,     'travis/api/v2/http/accounts'
        autoload :Artifact,     'travis/api/v2/http/artifact'
        autoload :Branches,     'travis/api/v2/http/branches'
        autoload :Build,        'travis/api/v2/http/build'
        autoload :Builds,       'travis/api/v2/http/builds'
        autoload :Hooks,        'travis/api/v2/http/hooks'
        autoload :Job,          'travis/api/v2/http/job'
        autoload :Jobs,         'travis/api/v2/http/jobs'
        autoload :Repositories, 'travis/api/v2/http/repositories'
        autoload :Repository,   'travis/api/v2/http/repository'
        autoload :User,         'travis/api/v2/http/user'
        autoload :Workers,      'travis/api/v2/http/workers'
      end
    end
  end
end
