module Travis
  module Api
    module V1
      module Pusher
        class Build
          class Finished < Build
            def data
              { 'build' => build_data, 'repository' => repository_data }
            end

            def build_data
              {
                'id' => build.id,
                'result' => build.result,
                'finished_at' => format_date(build.finished_at),
                'duration' => build.duration,
                'state' => build.state.to_s
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
                'last_build_result' => repository.last_build_result,
              }
            end
          end
        end
      end
    end
  end
end


