module Travis
  module Api
    module V1
      module Pusher
        class Worker
          attr_reader :worker

          def initialize(worker, options = {})
            @worker = worker
          end

          def data
            {
              'id' => worker.id,
              'host' => worker.host,
              'name' => worker.name,
              'state' => worker.state,
              'payload' => worker.payload,
              'last_error' => worker.last_error
            }
          end
        end
      end
    end
  end
end
