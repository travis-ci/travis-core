# TODO include_logs? has been removed. gotta be deprecated!
#
module Travis
  module Addons
    module Webhook

      # Sends build notifications to webhooks as defined in the configuration
      # (`.travis.yml`).
      class EventHandler < Event::Handler
        API_VERSION = 'v1'

        EVENTS = /build:(started|finished)/

        def handle?
          !pull_request? && targets.present? && config.send_on?(:webhooks, event.split(':').last)
        end

        def handle
          Travis::Addons::Webhook::Task.run(:webhook, payload, targets: targets, token: request['token'])
        end

        def targets
          @targets ||= config.notification_values(:webhooks, :urls)
        end

        Instruments::EventHandler.attach_to(self)
      end
    end
  end
end
