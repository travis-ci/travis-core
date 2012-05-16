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

        def data(extra = {})
          Http::V2::Build.new(build).data
        end
      end
    end
  end
end
