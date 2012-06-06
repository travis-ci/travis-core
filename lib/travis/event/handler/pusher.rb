module Travis
  module Event
    class Handler

      # Notifies registered clients about various state changes through Pusher.
      class Pusher < Handler
        include do
          API_VERSION = 'v1'

          EVENTS = [/^build:(started|finished)/, /^job:test:(created|started|log|finished)/, /^worker:.*/]

          def notify
            handle if handle?
          end

          private

            def handle?
              true
            end

            def handle
              Task::Pusher.new(event, payload).run
            end

            def payload
              Api.data(object, :for => 'pusher', :type => type, :params => data, :version => API_VERSION)
            end

            def type
              event =~ /^worker:/ ? 'worker' : event.sub('test:', '').sub(':', '/')
            end
        end
      end
    end
  end
end
