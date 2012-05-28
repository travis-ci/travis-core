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

            attr_reader :data

            def send(channels, data)
              @channels = channels
              @data = data
              # Notifications to the same host are grouped so that they can be sent with a single connection
              channels.each do |server, channels|
                host, port = *server
                send_notifications(host, port, channels)
              end
            end

            def send_notifications(host, port, channels)
              client(host, nick, :port => port) do |client|
                channels.each do |channel|
                    send_notification(client, channel)
                    info("Successfully notified #{host}:#{port}##{channel}")
                  begin
                  rescue StandardError => e
                    error("Could not notify #{host}:#{port}##{channel} : #{e.inspect}")
                  end
                end
              end
            end

            def send_notification(client, channel)
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
              data['build']['config']['notifications'][:irc] rescue {}
            end

            def notice?
              config.is_a?(Hash) && !!config[:use_notice]
            end

            def join?
              config.is_a?(Hash) ? !config[:skip_join] : true
            end

            def messages
              @messages ||= templates.map do |template|
                Template.new(template, data).interpolate
              end
            end

            def templates
              templates = config[:template] rescue nil
              Array(templates || default_templates)
            end

            def default_templates
              [
                "%{repository}#%{build_number} (%{branch} - %{commit} : %{author}): %{message}",
                "Change view : %{compare_url}",
                "Build details : %{build_url}"
              ]
            end
        end
      end
    end
  end
end
