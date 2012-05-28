module Travis
  module Notifications
    class Handler

      # Notifies registered clients about various state changes through Pusher.
      class Pusher < Handler
        API_VERSION = 'v1'

        EVENTS = [/^build:(started|finished)/, /^job:test:(created|started|log|finished)/, /^worker:.*/]

        private

          def handle
            Task::Pusher.new(event, data).run
          end

          def data
            Api.data(object, :for => 'pusher', :type => type, :params => data, :version => API_VERSION)
          end

          def type
            event =~ /^worker:/ ? 'worker' : event.sub('test:', '').sub(':', '/')
          end
      end
    end
  end
end
