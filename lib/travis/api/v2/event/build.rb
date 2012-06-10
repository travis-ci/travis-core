module Travis
  module Api
    module V2
      module Event
        class Build
          attr_reader :build, :repository, :request

          def initialize(build, options)
            @build = build
            @repository = build.repository
            @request = build.request
          end

          def data(extra = {})
            request_data.merge(repository_data.merge(build_data))
          end

          private

            def build_data
              Http::Build.new(build).data
            end

            def repository_data
              Http::Repository.new(repository).data
            end

            def request_data
              {
                'request' => {
                  'head_commit' => (request.head_commit || '')[0..7],
                  'base_commit' => (request.base_commit || '')[0..7]
                }
              }
            end
        end
      end
    end
  end
end

