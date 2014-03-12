module Travis
  module Addons
    module Slack

      # Publishes a build notification to Slack rooms as defined in the
      # configuration (`.travis.yml`).
      #
      # Slack credentials are encrypted using the repository's ssl key.
      class EventHandler < Event::Handler
        API_VERSION = 'v2'

        EVENTS = /build:finished/

        def handle?
          handle = targets.present? && config.send_on_finished_for?(:slack)
          Travis.logger.info("Handle Slack request? #{handle}")
          handle
        end

        def handle
          Travis::Addons::Slack::Task.run(:slack, payload, targets: targets)
        end

        def targets
          @targets ||= config.notification_values(:slack, :rooms)
          Travis.logger.info("Targets for Slack: #{@targets}")
          @targets
        end

        Instruments::EventHandler.attach_to(self)
      end
    end
  end
end
