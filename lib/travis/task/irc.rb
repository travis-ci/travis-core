module Travis
  class Task
    # Publishes a build notification to IRC channels as defined in the
    # configuration (`.travis.yml`).
    class Irc < Task
      autoload :Client,   'travis/task/irc/client'
      autoload :Template, 'travis/task/irc/template'

      TEMPLATES = [
        "%{repository}#%{build_number} (%{branch} - %{commit} : %{author}): %{message}",
        "Change view : %{compare_url}",
        "Build details : %{build_url}"
      ]

      def channels
        options[:channels]
      end

      def messages
        @messages ||= templates.map do |template|
          Template.new(template, data).interpolate
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
          Array(templates || TEMPLATES)
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
          config[:nick] || Travis.config.irc.try(:nick) || 'travis-ci'
        end

        def password
          config[:password]
        end

        def nickserv_password
          config[:nickserv_password]
        end

        def config
          data['build']['config']['notifications'][:irc] rescue {}
        end

        Notification::Instrument::Task::Irc.attach_to(self)
    end
  end
end
