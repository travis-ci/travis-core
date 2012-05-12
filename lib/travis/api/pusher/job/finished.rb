module Travis
  module Api
    module Pusher
      class Job
        class Finished < Job
          def data
            {
              'id' => job.id,
              'build_id' => job.source_id,
              'finished_at' => format_date(job.finished_at),
              'result' => job.result
            }
          end
        end
      end
    end
  end
end
