# TODO include_logs? has been removed. gotta be deprecated!
#
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
          !pull_request? && targets.present? && config.send_on?(:webhooks, event.split(':').last)
        end

        def handle
          Task.run(:webhook, payload, targets: targets, token: request['token'])
        end

        def targets
          @targets ||= config.notification_values(:webhooks, :urls)
        end

        Notification::Instrument::Event::Handler::Webhook.attach_to(self)
      end
    end
  end
end
