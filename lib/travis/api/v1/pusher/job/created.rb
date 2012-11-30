module Travis
  module Api
    module V1
      module Pusher
        class Job
          class Created < Job
            def data
              {
                'id' => job.id,
                'build_id' => job.source_id,
                'repository_id' => job.repository_id,
                'repository_slug' => job.repository.slug,
                'number' => job.number,
                'queue' => job.queue,
                'state' => job.state.to_s,
                'log_id' => job.log.id,
                'allow_failure' => job.allow_failure,
                'result' => job.result,
                'started_at' => format_date(job.started_at),
                'finished_at' => format_date(job.finished_at)
              }
            end
          end
        end
      end
    end
  end
end
