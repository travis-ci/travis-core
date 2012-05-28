module Travis
  module Notifications
    class Handler

      # Publishes a build notification to campfire rooms as defined in the
      # configuration (`.travis.yml`).
      #
      # Campfire credentials are encrypted using the repository's ssl key.
      class Campfire < Handler
        API_VERSION = 'v2'

        EVENTS = /build:finished/

        private

          def handle?
            object.send_campfire_notifications_on_finish?
          end

          def handle
            Task::Campfire.new(targets, data).run if handle?
          end

          def targets
            object.campfire_rooms
          end

          def data
            Api.data(object, :for => 'notifications', :version => API_VERSION)
          end
      end
    end
  end
end
