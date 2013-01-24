module Travis
  module Addons
    module Archive
      class EventHandler < Event::Handler
        API_VERSION = 'v2'

        EVENTS = /log:aggregated/

        def handle?
          true
        end

        def handle
          Travis::Addons::Archive::Task.run(:archive, payload)
        end

        def payload
          @payload ||= { type: type, id: object.id }
        end

        def type
          @type ||= event.split(':').first
        end

        class Instrument < Notification::Instrument::EventHandler
          def notify_completed
            publish(payload: handler.payload)
          end
        end
        Instrument.attach_to(self)
      end
    end
  end
end
