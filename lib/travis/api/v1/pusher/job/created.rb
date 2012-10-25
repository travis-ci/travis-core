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
                'number' => job.number,
                'queue' => job.queue,
                'state' => job.state.to_s
              }
            end
          end
        end
      end
    end
  end
end
