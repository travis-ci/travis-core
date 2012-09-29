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

        def handle?
          config.send_on_finish?
        end

        def handle
          Task.run(:flowdock, payload, :targets => targets)
        end

        def targets
          @targets ||= config.rooms
        end

        def payload
          @payload ||= Api.data(object, :for => 'event', :version => API_VERSION)
        end

        def config
          @config ||= Config::Flowdock.new(object)
        end

        Notification::Instrument::Event::Handler::Flowdock.attach_to(self)
      end
    end
  end
end
