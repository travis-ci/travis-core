module Travis
  module Event
    class Handler

      # Receives incoming events, such as request:created, job:configure:created, job:test:logged?
      class Hub < Handler
        include do
          API_VERSION = 'v1'

          EVENTS = [/^build:(started|finished)/, /^job:test:(created|started|log|finished)/, /^worker:.*/]

          private

            def handle?
              true
            end

            def handle
            end
        end
      end
    end
  end
end

