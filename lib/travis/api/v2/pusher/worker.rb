module Travis
  module Api
    module V2
      module Pusher
        class Worker
          attr_reader :worker, :options

          def initialize(worker, options = {})
            @worker = worker
            @options = options
          end

          def data(extra = {})
            {
              'worker' => worker_data(worker)
            }
          end

          private

            def worker_data(worker)
              {
                'id' => worker.id,
                'host' => worker.host,
                'name' => worker.name,
                'state' => worker.state.to_s,
                'payload' => worker.payload
              }
            end
        end
      end
    end
  end
end
