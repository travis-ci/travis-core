require 'core_ext/module/include'
require 'irc_client'

module Travis
  module Notifications
    module Handler
      # Publishes a build notification to IRC channels as defined in the
      # configuration (`.travis.yml`).
      class Irc
        autoload :Template, 'travis/notifications/handler/irc/template'

        API_VERSION = 'v2'

        EVENTS = 'build:finished'

        include Logging

        include do
          attr_reader :build

          def notify(event, build, *args)
            @build = build
            send(channels, payload) if send?
          end

          private

            def send?
              build.send_irc_notifications_on_finish?
            end

            def channels
              build.irc_channels
            end

            def payload
              Api.data(build, :for => 'notifications', :version => API_VERSION)
            end

            # TODO --- extract ---

            def send(channels, data)
              # Notifications to the same host are grouped so that they can be sent with a single connection
              channels.each do |server, channels|
                host, port = *server
                send_notifications(host, port, channels)
              end
            end

            def send_notifications(host, port, channels)
              client(host, nick, :port => port) do |client|
                channels.each do |channel|
                  begin
                    send_notification(client, channel, interpolated_messages)
                    info("Successfully notified #{host}:#{port}##{channel}")
                  rescue StandardError => e
                    error("Could not notify #{host}:#{port}##{channel} : #{e.inspect}")
                  end
                end
              end
            end

            def send_notification(client, channel, messages)
              client.join(channel) if join?
              messages.each { |message| client.say("[travis-ci] #{message}", channel, notice?) }
              client.leave(channel) if join?
            end

            def client(host, nick, options, &block)
              IrcClient.new(host, nick, options).tap do |client|
                client.run(&block) if block_given?
                client.quit
              end
            end

            def nick
              Travis.config.irc.try(:nick) || 'travis-ci'
            end

            def config
              build.config[:notifications][:irc]
            end

            def notice?
              config.is_a?(Hash) && !!config[:use_notice]
            end

            def join?
              config.is_a?(Hash) ? !config[:skip_join] : true
            end

            def messages
              @messages ||= templates.map do |template|
                Template.new(templaet, build).interpolate
              end
            end

            def templates
              @template ||= begin
                template = (build.config[:notifications] && build.config[:notifications][:irc].is_a?(Hash) && build.config[:notifications][:irc][:template])
                Array(template || default_template)
              end
            end

            def default_template
              ["%{repository_url}#%{build_number} (%{branch} - %{commit} : %{author}): %{message}",
                "Change view : %{compare_url}",
                "Build details : %{build_url}"]
            end
        end
      end
    end
  end
end
