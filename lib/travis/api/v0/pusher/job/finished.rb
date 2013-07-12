module Travis
  module Api
    module V0
      module Pusher
        class Job
          class Finished < Job
            include V1::Helpers::Legacy

            def data
              {
                'id' => job.id,
                'build_id' => job.source_id,
                'repository_id' => job.repository_id,
                'repository_slug' => job.repository.slug,
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
