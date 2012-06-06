module Travis
  module Event
    class Handler
      class Archive < Handler
        include do
          API_VERSION = 'v1'

          EVENTS = 'build:finished'

          def notify
            handle if handle?
          end

          private

            def handle?
              true
            end

            def handle
              Task::Archive.new(payload).run
            end

            def payload
              Api.data(object, :for => 'archive', :version => API_VERSION)
            end
        end
      end
    end
  end
end
