module Travis
  module Notifications
    module Json
      module Pusher
        class Build
          class Finished < Build
            def data
              { 'build' => build_data, 'repository' => repository_data }
            end

            def build_data
              {
                'id' => build.id,
                'result' => 0,
                'finished_at' => build.finished_at.strftime('%Y-%m-%dT%H:%M:%SZ')
              }
            end

            def repository_data
              {
                'id' => repository.id,
                'slug' => repository.slug,
                'last_build_id' => repository.last_build_id,
                'last_build_number' => repository.last_build_number,
                'last_build_started_at' => repository.last_build_started_at.strftime('%Y-%m-%dT%H:%M:%SZ'),
                'last_build_finished_at' => repository.last_build_finished_at.strftime('%Y-%m-%dT%H:%M:%SZ'),
                'last_build_duration' => repository.last_build_duration,
                'last_build_result' => repository.last_build_status,
              }
            end
          end
        end
      end
    end
  end
end


