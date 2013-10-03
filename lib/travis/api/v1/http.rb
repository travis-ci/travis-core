module Travis
  module Api
    module V1
      module Http
        autoload :Branch,       'travis/api/v1/http/branch'
        autoload :Branches,     'travis/api/v1/http/branches'
        autoload :Build,        'travis/api/v1/http/build'
        autoload :Builds,       'travis/api/v1/http/builds'
        autoload :Hooks,        'travis/api/v1/http/hooks'
        autoload :Job,          'travis/api/v1/http/job'
        autoload :Jobs,         'travis/api/v1/http/jobs'
        autoload :Repositories, 'travis/api/v1/http/repositories'
        autoload :Repository,   'travis/api/v1/http/repository'
        autoload :User,         'travis/api/v1/http/user'
        autoload :Workers,      'travis/api/v1/http/workers'
      end
    end
  end
end
