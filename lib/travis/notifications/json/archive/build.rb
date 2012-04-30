module Travis
  module Notifications
    module Json
      module Archive
        class Build
          autoload :Test,  'travis/notifications/json/archive/build/test'

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
