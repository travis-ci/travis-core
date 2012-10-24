module Travis
  module Event
    class Handler

      # Publishes a build notification to campfire rooms as defined in the
      # configuration (`.travis.yml`).
      #
      # Campfire credentials are encrypted using the repository's ssl key.
      class Hipchat < Handler
        API_VERSION = 'v2'

        EVENTS = /build:finished/

        def handle?
          !pull_request? && targets.present? && config.send_on_finished_for?(:hipchat)
        end

        def handle
          Task.run(:hipchat, payload, targets: targets)
        end

        def targets
          @targets ||= config.notification_values(:hipchat, :rooms)
        end

        Notification::Instrument::Event::Handler::Hipchat.attach_to(self)
      end
    end
  end
end
