module Travis
  module Api
    module V1
      module Pusher
        class Worker
          attr_reader :worker

          include Formats

          def initialize(worker, options = {})
            @worker = worker
          end

          def data
            {
              'id' => worker.id,
              'host' => worker.host,
              'name' => worker.name,
              'state' => worker.state,
              'payload' => worker.payload
            }
          end
        end
      end
    end
  end
end
