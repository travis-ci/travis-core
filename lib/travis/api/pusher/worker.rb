module Travis
  module Api
    module Pusher
      class Worker
        attr_reader :worker

        def initialize(worker)
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
