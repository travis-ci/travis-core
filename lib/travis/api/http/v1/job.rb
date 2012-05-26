module Travis
  module Api
    module Http
      module V1
        module Job
          autoload :Test,  'travis/api/http/v1/job/test'
          autoload :Tests, 'travis/api/http/v1/job/tests'
        end
      end
    end
  end
end
