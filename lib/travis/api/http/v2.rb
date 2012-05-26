module Travis
  module Api
    module Http
      module V2
        autoload :Branches,     'travis/api/http/v2/branches'
        autoload :Build,        'travis/api/http/v2/build'
        autoload :Builds,       'travis/api/http/v2/builds'
        autoload :Job,          'travis/api/http/v2/job'
        autoload :Jobs,         'travis/api/http/v2/jobs'
        autoload :Repositories, 'travis/api/http/v2/repositories'
        autoload :Repository,   'travis/api/http/v2/repository'
        autoload :Workers,      'travis/api/http/v2/workers'
      end
    end
  end
end

