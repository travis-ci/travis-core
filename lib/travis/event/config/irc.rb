module Travis
  module Event
    class Config
      class Irc < Config
        def send_on_finish?
          !build.pull_request? && channels.present? && send_on_finish_for?(:irc)
        end
      end

      def channels
        @channels ||= notification_values(:irc, :channels).inject(Hash.new([])) do |servers, url|
          # TODO parsing irc urls should probably happen in the client class
          server_and_port, channel = url.split('#', 2)
          server, port = server_and_port.split(':')
          servers[[server, port]] += [channel]
          servers
        end
      end
    end
  end
end
