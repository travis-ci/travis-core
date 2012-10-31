module Travis
  module Addons
    module Irc

      # Publishes a build notification to IRC channels as defined in the
      # configuration (`.travis.yml`).
      class Task < Travis::Task
        DEFAULT_TEMPLATE = [
          "%{repository}#%{build_number} (%{branch} - %{commit} : %{author}): %{message}",
          "Change view : %{compare_url}",
          "Build details : %{build_url}"
        ]

        def channels
          @channels ||= params[:channels]
          # @channels ||= options[:channels].inject({}) do |channels, (key, value)|
          #   key = eval(key) if key.is_a?(String)
          #   channels.merge(key => value)
          # end
        end

        def messages
          @messages ||= templates.map do |template|
            Util::Template.new(template, payload).interpolate
          end
        end

        private

          def process
            # Notifications to the same host are grouped so that they can be sent with a single connection
            parsed_channels.each do |server, channels|
              host, port, ssl = *server
              send_messages(host, port, ssl, channels)
            end
          end

          def send_messages(host, port, ssl, channels)
            client(host, nick, client_options(port, ssl)) do |client|
              channels.each do |channel|
                begin
                  send_message(client, channel)
                  info("Successfully notified #{host}:#{port}##{channel}")
                # rescue StandardError => e
                #   error("Could not notify #{host}:#{port}##{channel} : #{e.inspect}")
                end
              end
            end
          end

          def send_message(client, channel)
            client.join(channel) if join?
            messages.each { |message| client.say("[travis-ci] #{message}", channel, notice?) }
            client.leave(channel) if join?
          end

          # TODO move parsing irc urls to irc client class
          def parsed_channels
            channels.inject(Hash.new([])) do |servers, url|
              uri = Addressable::URI.heuristic_parse(url, :scheme => 'irc')
              ssl = uri.scheme == 'irc' ? nil : :ssl
              servers[[uri.host, uri.port, ssl]] += [uri.fragment]
              servers
            end
          end

          def notice?
            !!config[:use_notice]
          end

          def join?
            !config[:skip_join]
          end

          def templates
            Array(config[:template] || DEFAULT_TEMPLATE)
          end

          def client_options(port, ssl)
            {
              :port => port,
              :ssl => (ssl == :ssl),
              :password => config[:password],
              :nickserv_password => config[:nickserv_password]
            }
          end

          def client(host, nick, options, &block)
            client = Client.new(host, nick, options)
            client.run(&block) if block_given?
            client.quit
          end

          def nick
            config[:nick] || Travis.config.irc.try(:nick) || 'travis-ci'
          end

          def config
            build[:config][:notifications][:irc] || {} rescue {}
          end

          Instruments::Task.attach_to(self)
      end
    end
  end
end

