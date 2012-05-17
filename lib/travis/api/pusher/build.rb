module Travis
  module Api
    module Pusher
      class Build
        autoload :Started,  'travis/api/pusher/build/started'
        autoload :Finished, 'travis/api/pusher/build/finished'

        include Formats

        attr_reader :build, :repository

        def initialize(build)
          @build = build
          @repository = build.repository
        end

        def data(extra = {})
          repository_data.merge(build_data)
        end

        private

          def build_data
            Http::V2::Build.new(build).data
          end

          def repository_data
            Http::V2::Repository.new(build.repository).data
          end
      end
    end
  end
end
