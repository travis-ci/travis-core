module Travis
  module Event
    class Handler

      # Publishes a build notification to Flowdock rooms as defined in the
      # configuration (`.travis.yml`).
      #
      # Flowdock credentials are encrypted using the repository's ssl key.
      class Flowdock < Handler
        API_VERSION = 'v2'

        EVENTS = /build:finished/

        def initialize(*)
          super
          @payload = Api.data(object, for: 'event', version: 'v0', params: data)
        end

        def handle?
          !pull_request? && targets.present? && config.send_on_finished_for?(:flowdock)
        end

        def handle
          Task.run(:flowdock, payload, targets: targets)
        end

        def targets
          @targets ||= config.notification_values(:flowdock, :rooms)
        end

        Notification::Instrument::Event::Handler::Flowdock.attach_to(self)
      end
    end
  end
end
