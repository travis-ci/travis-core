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

        attr_reader :payload, :targets

        def initialize(*)
          super
          if handle?
            @payload = Api.data(object, :for => 'event', :version => API_VERSION)
            @targets = config.rooms
          end
        end

        def handle?
          config.send_on_finish?
        end

        def handle
          Task.run(:hipchat, payload, :targets => targets)
        end

        private

          def config
            @config ||= Config::Hipchat.new(object)
          end

          Notification::Instrument::Event::Handler::Hipchat.attach_to(self)
      end
    end
  end
end
