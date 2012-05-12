module Travis
  module Api
    module Json
      module Http
        module V1
          autoload :Branches,     'travis/api/json/http/v1/branches'
          autoload :Build,        'travis/api/json/http/v1/build'
          autoload :Builds,       'travis/api/json/http/v1/builds'
          autoload :Job,          'travis/api/json/http/v1/job'
          autoload :Repositories, 'travis/api/json/http/v1/repositories'
          autoload :Repository,   'travis/api/json/http/v1/repository'
          autoload :Workers,      'travis/api/json/http/v1/workers'
        end
      end
    end
  end
end
