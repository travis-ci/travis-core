require 'addressable/uri'

module Travis
  module Event
    class Handler
      # Publishes a build notification to IRC channels as defined in the
      # configuration (`.travis.yml`).
      class Irc < Handler
        API_VERSION = 'v2'

        EVENTS = 'build:finished'

        def handle?
          !pull_request? && channels.present? && config.send_on_finished_for?(:irc)
        end

        def handle
          Task.run(:irc, payload, channels: channels)
        end

        def channels
          @channels ||= config.notification_values(:irc, :channels)
        end

        Notification::Instrument::Event::Handler::Irc.attach_to(self)
      end
    end
  end
end
