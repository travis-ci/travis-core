module Travis
  module Api
    module V1
      module Pusher
        class Job
          class Finished < Job
            include Helpers::Legacy

            def data
              {
                'id' => job.id,
                'build_id' => job.source_id,
                'repository_id' => job.repository_id,
                'state' => job.state.to_s,
                'result' => legacy_job_result(job),
                'finished_at' => format_date(job.finished_at)
              }
            end
          end
        end
      end
    end
  end
end
