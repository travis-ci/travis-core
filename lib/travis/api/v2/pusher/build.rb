module Travis
  module Api
    module V2
      module Pusher
        class Build
          autoload :Started,  'travis/api/v2/pusher/build/started'
          autoload :Finished, 'travis/api/v2/pusher/build/finished'

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
              Http::Build.new(build).data
            end

            def repository_data
              Http::Repository.new(build.repository).data
            end
        end
      end
    end
  end
end
