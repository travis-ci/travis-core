module Travis
  module Api
    module V2
      module Http
        class Workers
          include Formats

          attr_reader :workers, :options

          def initialize(workers, options = {})
            @workers = workers
            @options = options
          end

          def data
            {
              'workers' => workers.map { |worker| worker_data(worker) }
            }
          end

          private

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
