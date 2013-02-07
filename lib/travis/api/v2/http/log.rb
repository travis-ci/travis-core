module Travis
  module Api
    module V2
      module Http
        class Log
          attr_reader :log, :options

          def initialize(log, options = {})
            @log = log
            @options = options
          end

          def data
            {
              'log' => log_data,
            }
          end

          private

            def log_data
              {
                'id' => log.id,
                'job_id' => log.job_id,
                'type' => log.class.name.demodulize,
                'body' => log.content
              }
            end
        end
      end
    end
  end
end

