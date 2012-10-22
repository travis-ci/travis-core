module Travis
  module Event
    class Handler
      # Publishes a build notification to IRC channels as defined in the
      # configuration (`.travis.yml`).
      class Irc < Handler
        API_VERSION = 'v2'

        EVENTS = 'build:finished'

        attr_reader :payload, :channels

        def initialize(*)
          super
          if handle?
            @payload = Api.data(object, :for => 'event', :version => API_VERSION)
            @channels = config.channels
          end
        end

        def handle?
          config.send_on_finish?
        end

        def handle
          Task.run(:irc, payload, :channels => channels)
        end

        private

          def config
            @config ||= Config::Irc.new(object)
          end

          Notification::Instrument::Event::Handler::Irc.attach_to(self)
      end
    end
  end
end
