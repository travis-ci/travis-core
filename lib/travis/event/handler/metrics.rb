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
            events = %W(job.queue.wait_time job.queue.wait_time.#{queue})
            meter(events, object.created_at, object.started_at)
          when 'job:test:finished'
            events = %W(job.duration job.duration.#{queue})
            meter(events, object.started_at, object.finished_at)
          end
        end

        private

          def queue
            object.queue.gsub('.', '-')
          end

          def meter(events, started_at, finished_at)
            events.each do |event|
              Travis::Instrumentation.meter(event, :started_at => started_at, :finished_at => finished_at)
            end
          end
      end
    end
  end
end

