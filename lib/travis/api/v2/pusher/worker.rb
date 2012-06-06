module Travis
  module Api
    module V2
      module Pusher
        class Worker
          attr_reader :worker

          def initialize(worker)
            @worker = worker
          end

          def data(extra = {})
            { 'worker' => worker_data(worker) }
          end

          private

            def worker_data(worker)
              {
                'id' => worker.id,
                'host' => worker.host,
                'name' => worker.name,
                'state' => worker.state.to_s,
                'payload' => worker.payload,
                'last_error' => worker.last_error
              }
            end
        end
      end
    end
  end
end
