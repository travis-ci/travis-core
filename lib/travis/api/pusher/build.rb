module Travis
  module Api
    module Pusher
      class Build
        autoload :Started,  'travis/api/pusher/build/started'
        autoload :Finished, 'travis/api/pusher/build/finished'

        include Formats

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
