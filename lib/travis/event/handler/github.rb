module Travis
  module Event
    class Handler

      # Adds a comment with a build notification to the pull-request the request
      # belongs to.
      class Github < Handler
        API_VERSION = 'v2'

        EVENTS = /build:finished/

        def handle?
          object.pull_request?
        end

        def handle
          Task.run(:github, payload, :url => url)
        end

        def url
          object.request.comments_url
        end

        def payload
          @payload ||= Api.data(object, :for => 'event', :version => API_VERSION)
        end

        Notification::Instrument::Event::Handler::Github.attach_to(self)
      end
    end
  end
end
