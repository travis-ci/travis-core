module Travis
  module Event
    class Handler

      # Stores metrics about domain events
      class Metrics < Handler
        EVENTS = /job:test:(started|finished)/

        def handle?
          true
        end

        def handle
          case event
          when 'job:test:started'
            meter('job.queue.wait_time', object.created_at, object.started_at)
          when 'job:test:finished'
            meter('job.duration', object.started_at, object.finished_at)
          end
        end

        private

          def meter(event, started_at, finished_at)
            Travis::Instrumentation.meter(event, :started_at => started_at, :finished_at => finished_at)
          end
      end
    end
  end
end

