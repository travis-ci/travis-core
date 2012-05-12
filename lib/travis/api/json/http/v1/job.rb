module Travis
  module Api
    module Json
      module Http
        module V1
          module Job
            autoload :Test,  'travis/api/json/http/v1/job/test'
            autoload :Tests, 'travis/api/json/http/v1/job/tests'
          end
        end
      end
    end
  end
end
