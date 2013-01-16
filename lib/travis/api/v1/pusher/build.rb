module Travis
  module Api
    module V1
      module Pusher
        class Build
          autoload :Created,  'travis/api/v1/pusher/build/created'
          autoload :Started,  'travis/api/v1/pusher/build/started'
          autoload :Finished, 'travis/api/v1/pusher/build/finished'

          include Formats

          attr_reader :build

          def initialize(build, options = {})
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

