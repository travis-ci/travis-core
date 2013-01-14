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
              'payload' => worker.payload,
              'last_error' => worker.last_error,
              'last_seen_at' => format_date(worker.last_seen_at)
            }
          end
        end
      end
    end
  end
end
