module Travis
  module Api
    module Pusher
      class Job
        class Log < Job
          def data
            {
              'id' => job.id,
            }
          end
        end
      end
    end
  end
end
