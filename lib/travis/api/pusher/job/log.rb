module Travis
  module Api
    module Pusher
      class Job
        class Log < Job
          def data(extra = {})
            { 'job' => { 'id' => job.id }.merge(extra) }
          end
        end
      end
    end
  end
end
