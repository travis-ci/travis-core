module Travis
  module Event
    class Handler

      # Adds a comment with a build notification to the pull-request the request
      # belongs to.
      class Github < Handler
        include do
          API_VERSION = 'v2'

          EVENTS = /build:finished/

          def notify
            handle if handle?
          end

          private

            def handle?
              object.request.pull_request?
            end

            def handle
              Task::Github.new(url, data).run
            end

            def url
              object.request.comments_url
            end

            def data
              Api.data(object, :for => 'event', :version => API_VERSION)
            end
        end
      end
    end
  end
end
