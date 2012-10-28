module Travis
  module Addons
    module Hipchat

      # Publishes a build notification to campfire rooms as defined in the
      # configuration (`.travis.yml`).
      #
      # Campfire credentials are encrypted using the repository's ssl key.
      class EventHandler < Event::Handler
        API_VERSION = 'v2'

        EVENTS = /build:finished/

        def handle?
          !pull_request? && targets.present? && config.send_on_finished_for?(:hipchat)
        end

        def handle
          Travis::Addons::Hipchat::Task.run(:hipchat, payload, targets: targets)
        end

        def targets
          @targets ||= config.notification_values(:hipchat, :rooms)
        end

        Instruments::EventHandler.attach_to(self)
      end
    end
  end
end

