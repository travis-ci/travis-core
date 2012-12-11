module Travis
  module Api
    module V1
      module Pusher
        class Job
          class Created < Job
            include Helpers::Legacy

            def data
              {
                'id' => job.id,
                'build_id' => job.source_id,
                'repository_id' => job.repository_id,
                'repository_slug' => job.repository.slug,
                'number' => job.number,
                'queue' => job.queue,
                'state' => job.state.to_s,
                'result' => legacy_job_result(job),
                'log_id' => job.log.id,
                'allow_failure' => job.allow_failure
              }
            end
          end
        end
      end
    end
  end
end
