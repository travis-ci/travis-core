module Travis
  module Api
    module Json
      module Pusher
        class Build
          autoload :Started,  'travis/api/json/pusher/build/started'
          autoload :Finished, 'travis/api/json/pusher/build/finished'

          attr_reader :build

          def initialize(build)
            @build = build
          end

          def commit
            build.commit
          end

          def request
            build.request
          end

          def repository
            build.repository
          end
        end
      end
    end
  end
end

