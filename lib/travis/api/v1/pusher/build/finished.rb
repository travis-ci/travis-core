module Travis
  module Api
    module V1
      module Pusher
        class Build
          class Finished < Build
            include Helpers::Legacy

            def data
              { 'build' => build_data, 'repository' => repository_data }
            end

            def build_data
              {
                'id' => build.id,
                'state' => build.state.to_s,
                'result' => legacy_build_result(build),
                'finished_at' => format_date(build.finished_at),
                'duration' => build.duration
              }
            end

            def repository_data
              {
                'id' => repository.id,
                'slug' => repository.slug,
                'last_build_id' => repository.last_build_id,
                'last_build_number' => repository.last_build_number,
                'last_build_started_at' => format_date(repository.last_build_started_at),
                'last_build_finished_at' => format_date(repository.last_build_finished_at),
                'last_build_duration' => repository.last_build_duration,
                'last_build_state' => repository.last_build_state.to_s,
                'last_build_result' => legacy_repository_last_build_result(repository),
                'description' => repository.description
              }
            end
          end
        end
      end
    end
  end
end


