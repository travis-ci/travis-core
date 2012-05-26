module Travis
  module Api
    module V1
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
end

