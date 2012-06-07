module Travis
  module Event
    class Handler
      class Archive < Handler
        API_VERSION = 'v1'

        EVENTS = 'build:finished'

        private

          def handle?
            true
          end

          def handle
            Task.run(:archive, payload)
          end

          def payload
            Api.data(object, :for => 'archive', :version => API_VERSION)
          end
      end
    end
  end
end
