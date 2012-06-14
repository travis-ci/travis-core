module Travis
  module Event
    class Handler
      # Publishes a build notification to IRC channels as defined in the
      # configuration (`.travis.yml`).
      class Irc < Handler
        API_VERSION = 'v2'

        EVENTS = 'build:finished'

        def handle?
          config.send_on_finish?
        end

        def handle
          Task.run(:irc, payload, :channels => channels)
        end

        def payload
          @payload ||= Api.data(object, :for => 'event', :version => API_VERSION)
        end

        def channels
          config.channels
        end

        def config
          @config ||= Config::Irc.new(object)
        end

        Notification::Instrument::Event::Handler::Irc.attach_to(self)
      end
    end
  end
end
