module Travis
  module Notifications
    module Json
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

