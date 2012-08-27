require 'faraday'

module Travis
  module Event
    class Handler

      # Sends build notifications to webhooks as defined in the configuration
      # (`.travis.yml`).
      class Webhook < Handler
        API_VERSION = 'v1'

        EVENTS = /build:(started|finished)/

        def handle?
          case event
          when 'build:started'
            config.send_on_start?
          when 'build:finished'
            config.send_on_finish?
          end
        end

        def handle
          Task.run(:webhook, payload, :targets => targets, :token => token)
        end

        def payload
          @payload ||= Api.data(object,
            :for => 'webhook',
            :type => 'build/finished',
            :params => { :include_log => config.include_log? },
            :version => API_VERSION
          )
        end

        def token
          object.request.token
        end

        def targets
          config.webhooks
        end

        def config
          @config ||= Config::Webhook.new(object)
        end

        Notification::Instrument::Event::Handler::Webhook.attach_to(self)
      end
    end
  end
end
