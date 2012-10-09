module Travis
  module Api
    module V2
      module Http
        class Worker
          include Formats

          attr_reader :worker, :options

          def initialize(worker, options = {})
            @worker = worker
            @options = options
          end

          def data
            {
              'worker' => worker_data
            }
          end

          private

            def worker_data
              {
                'id' => worker.id,
                'name' => worker.name,
                'host' => worker.host,
                'state' => worker.state.to_s,
                'last_seen_at' => format_date(worker.last_seen_at),
                'payload' => worker.payload,
                'last_error' => worker.last_error
              }
            end
        end
      end
    end
  end
end

