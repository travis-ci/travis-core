require "addressable/uri"
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
          u = Addressable::URI.heuristic_parse(url, scheme: 'irc')
          port_str_for_compat = u.port.nil? ? nil : u.port.to_s
          if u.scheme == 'irc'
            servers[[u.host, port_str_for_compat]] += [u.fragment]
          else
            servers[[u.host, port_str_for_compat, :ssl]] += [u.fragment]
          end
          servers
        end
      end
    end
  end
end
