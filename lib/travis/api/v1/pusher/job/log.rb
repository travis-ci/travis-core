module Travis
  module Api
    module V1
      module Pusher
        class Job
          class Log < Job
            def data
              {
                'id' => job.id,
                'build_id' => job.source_id,
                'repository_id' => job.repository_id,
                '_log' => options[:_log],
                'number' => options[:number],
                'final' => options[:final]
              }
            end
          end
        end
      end
    end
  end
end

