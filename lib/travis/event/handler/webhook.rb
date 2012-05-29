require 'faraday'

module Travis
  module Event
    class Handler

      # Sends build notifications to webhooks as defined in the configuration
      # (`.travis.yml`).
      class Webhook < Handler
        API_VERSION = 'v1'

        EVENTS = /build:(started|finished)/

        private

          def handle?
            case event
            when 'build:started'
              object.send_webhook_notifications_on_start?
            when 'build:finished'
              object.send_webhook_notifications_on_finish?
            end
          end

          def handle
            Task::Webhook.new(targets, data, token).run
          end

          def payload
            Api.data(object, :for => 'webhook', :type => 'build/finished', :version => API_VERSION)
          end

          def token
            object.request.token
          end

          def targets
            object.webhooks
          end
      end
    end
  end
end
