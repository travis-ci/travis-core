module Travis
  module Addons
    module Pusher

      # Notifies registered clients about various state changes through Pusher.
      class EventHandler < Event::Handler
        API_VERSION = 'v1'

        EVENTS = [
          /^build:(started|finished)/,
          /^job:test:(created|started|requeued|log|finished)/,
          /^worker:(added|updated|removed)/
        ]

        attr_reader :channels

        def initialize(*)
          super
          @payload = Api.data(object, :for => 'pusher', :type => type, :params => data, :version => API_VERSION) if handle?
        end

        def handle?
          true
        end

        def handle
          Travis::Addons::Pusher::Task.run(:pusher, payload, :event => event, :version => API_VERSION)
        end

        private

          def type
            if event =~ /^worker:/
              'worker'
            else
              event.sub('test:', '').sub(':', '/').sub('requeued', 'started')
            end
          end

          Instruments::EventHandler.attach_to(self)
      end
    end
  end
end

