module Travis
  module Api
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
            }
          end
        end
      end
    end
  end
end
