module Travis
  module Event
    class Handler
      # Publishes a build notification to IRC channels as defined in the
      # configuration (`.travis.yml`).
      class Irc < Handler
        include do
          API_VERSION = 'v2'

          EVENTS = 'build:finished'

          def notify
            handle if handle?
          end

          private

            def handle?
              object.send_irc_notifications_on_finish?
            end

            def handle
              Task::Irc.new(channels, data).run
            end

            def channels
              object.irc_channels
            end

            def data
              Api.data(object, :for => 'event', :version => API_VERSION)
            end
        end
      end
    end
  end
end
