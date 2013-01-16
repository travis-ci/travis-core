module Travis
  module Api
    module V1
      module Http
        class Workers
          include Formats

          attr_reader :workers

          def initialize(workers, options = {})
            @workers = workers
          end

          def data
            workers.map { |worker| worker_data(worker) }
          end

          def worker_data(worker)
            {
              'id' => worker.id,
              'name' => worker.name,
              'host' => worker.host,
              'state' => worker.state.to_s,
              'payload' => worker.payload
            }
          end
        end
      end
    end
  end
end
