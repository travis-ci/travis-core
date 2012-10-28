require 'multi_json'

module Travis
  class Task
    # Publishes a build notification to IRC channels as defined in the
    # configuration (`.travis.yml`).
    class Irc < Task
      autoload :Client,   'travis/task/irc/client'

      DEFAULT_TEMPLATE = [
        "%{repository}#%{build_number} (%{branch} - %{commit} : %{author}): %{message}",
        "Change view : %{compare_url}",
        "Build details : %{build_url}"
      ]

      def channels
        @channels ||= options[:channels].inject({}) do |channels, (key, value)|
          key = eval(key) if key.is_a?(String)
          channels.merge(key => value)
        end
      end

      def messages
        @messages ||= templates.map do |template|
          Shared::Template.new(template, data).interpolate
        end
      end

      private

        def process
          # Notifications to the same host are grouped so that they can be sent with a single connection
          channels.each do |server, channels|
            host, port, ssl = *server
            send_messages(host, port, ssl, channels)
          end
        end

        def send_messages(host, port, ssl, channels)
          client(host, nick, client_options(port, ssl)) do |client|
            channels.each do |channel|
                send_message(client, channel)
                info("Successfully notified #{host}:#{port}##{channel}")
              begin
              rescue StandardError => e
                error("Could not notify #{host}:#{port}##{channel} : #{e.inspect}")
              end
            end
          end
        end

        def send_message(client, channel)
          client.join(channel) if join?
          messages.each { |message| client.say("[travis-ci] #{message}", channel, notice?) }
          client.leave(channel) if join?
        end

        def notice?
          config.is_a?(Hash) && !!config[:use_notice]
        end

        def join?
          config.is_a?(Hash) ? !config[:skip_join] : true
        end

        def templates
          templates = config[:template] rescue nil
          Array(templates || DEFAULT_TEMPLATE)
        end

        def client_options(port, ssl)
          {
            :port => port,
            :ssl => (ssl == :ssl),
            :password => password,
            :nickserv_password => nickserv_password
          }
        end

        def client(host, nick, options, &block)
          Client.new(host, nick, options).tap do |client|
            client.run(&block) if block_given?
            client.quit
          end
        end

        def nick
          try_config(:nick) || Travis.config.irc.try(:nick) || 'travis-ci'
        end

        def password
          try_config(:password)
        end

        def nickserv_password
          try_config(:nickserv_password)
        end

        def try_config(option)
          config.is_a?(Hash) and config[option]
        end

        def config
          data['build']['config']['notifications'][:irc] rescue {}
        end

        Notification::Instrument::Task::Irc.attach_to(self)
    end
  end
end
