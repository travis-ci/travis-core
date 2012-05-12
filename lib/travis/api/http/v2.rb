module Travis
  module Api
    module Http
      module V2
        autoload :Branches,     'travis/api/http/v2/branches'
        autoload :Build,        'travis/api/http/v2/build'
        autoload :Builds,       'travis/api/http/v2/builds'
        autoload :Repositories, 'travis/api/http/v2/repositories'
        autoload :Repository,   'travis/api/http/v2/repository'
        autoload :Test,         'travis/api/http/v2/test'
        autoload :Tests,        'travis/api/http/v2/tests'
        autoload :Workers,      'travis/api/http/v2/workers'
      end
    end
  end
end

