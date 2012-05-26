module Travis
  module Api
    module Http
      module V1
        autoload :Branches,     'travis/api/http/v1/branches'
        autoload :Build,        'travis/api/http/v1/build'
        autoload :Builds,       'travis/api/http/v1/builds'
        autoload :Job,          'travis/api/http/v1/job'
        autoload :Jobs,         'travis/api/http/v1/jobs'
        autoload :Repositories, 'travis/api/http/v1/repositories'
        autoload :Repository,   'travis/api/http/v1/repository'
        autoload :Workers,      'travis/api/http/v1/workers'
      end
    end
  end
end
