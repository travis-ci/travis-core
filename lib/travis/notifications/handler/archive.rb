module Travis
  module Notifications
    class Handler
      class Archive < Handler
        API_VERSION = 'v1'

        EVENTS = 'build:finished'

        private

          def handle
            Task::Archive.new(data).run
          end

          def data
            Api.data(object, :for => 'archive', :version => API_VERSION)
          end
      end
    end
  end
end
