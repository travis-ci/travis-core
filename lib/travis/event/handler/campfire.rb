module Travis
  module Event
    class Handler

      # Publishes a build notification to campfire rooms as defined in the
      # configuration (`.travis.yml`).
      #
      # Campfire credentials are encrypted using the repository's ssl key.
      class Campfire < Handler
        API_VERSION = 'v2'

        EVENTS = /build:finished/

        def handle?
          object.send_campfire_notifications_on_finish?
        end

        def handle
          Task.run(:campfire, targets, payload)
        end

        def targets
          @targets ||= object.campfire_rooms
        end

        def payload
          @payload ||= Api.data(object, :for => 'event', :version => API_VERSION)
        end

        Instrument::Event::Handler::Campfire.attach_to(self)
      end
    end
  end
end
