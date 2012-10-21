module Travis
  module Api
    module V1
      module Pusher
        class Job
          class Finished < Job
            def data
              {
                'id' => job.id,
                'build_id' => job.source_id,
                'repository_id' => job.repository_id,
                'finished_at' => format_date(job.finished_at),
                'result' => job.result,
                'state' => job.state.to_s
              }
            end
          end
        end
      end
    end
  end
end
