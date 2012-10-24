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
          !pull_request? && targets.present? && config.send_on_finished_for?(:campfire)
        end

        def handle
          Task.run(:campfire, payload, targets: targets)
        end

        def targets
          @targets ||= config.notification_values(:campfire, :rooms)
        end

        Notification::Instrument::Event::Handler::Campfire.attach_to(self)
      end
    end
  end
end
