module Travis
  module Api
    module V2
      module Pusher
        class Build
          autoload :Started,  'travis/api/v2/pusher/build/started'
          autoload :Finished, 'travis/api/v2/pusher/build/finished'

          include Formats

          attr_reader :build, :repository, :options

          def initialize(build, options = {})
            @build = build
            @repository = build.repository
            @options = options
          end

          def data(extra = {})
            repository_data.merge(build_data)
          end

          private

            def build_data
              Http::Build.new(build).data
            end

            def repository_data
              {
                'repo' => {
                  'id' => repository.id,
                  'slug' => repository.slug,
                  'description' => repository.description,
                  'last_build_id' => repository.last_build_id,
                  'last_build_number' => repository.last_build_number,
                  'last_build_state' => repository.last_build_state.to_s,
                  'last_build_duration' => repository.last_build_duration,
                  'last_build_language' => repository.last_build_language,
                  'last_build_started_at' => format_date(repository.last_build_started_at),
                  'last_build_finished_at' => format_date(repository.last_build_finished_at),
                }
              }
            end
        end
      end
    end
  end
end
