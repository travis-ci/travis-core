module Travis
  module Addons
    module Pusher

      # Notifies registered clients about various state changes through Pusher.
      class EventHandler < Event::Handler
        EVENTS = [
          /^build:(created|started|finished|canceled)/,
          /^job:test:(created|started|log|finished|canceled)/,
          /^worker:(added|updated|removed)/
        ]

        attr_reader :channels

        def initialize(*)
          super
          @payload = Api.data(object, :for => 'pusher', :type => type, :params => data) if handle?
        end

        def handle?
          true
        end

        def handle
          Travis::Addons::Pusher::Task.run(:pusher, payload, :event => event)
        end

        private

          def type
            if event =~ /^worker:/
              'worker'
            else
              event.sub('test:', '').sub(':', '/')
            end
          end

          Instruments::EventHandler.attach_to(self)
      end
    end
  end
end

