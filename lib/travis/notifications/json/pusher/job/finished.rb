module Travis
  module Notifications
    module Json
      module Pusher
        class Job
          class Finished < Job
            def data
              {
                'id' => job.id,
                'build_id' => job.source_id,
                'finished_at' => job.finished_at,
                'result' => job.status
              }
            end
          end
        end
      end
    end
  end
end
