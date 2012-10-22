module Travis
  module Event
    class Handler

      # Adds a comment with a build notification to the pull-request the request
      # belongs to.
      class Github < Handler
        API_VERSION = 'v2'

        EVENTS = /build:finished/

        attr_reader :payload, :url

        def initialize(*)
          super
          if handle?
            @payload = Api.data(object, :for => 'event', :version => API_VERSION)
            @url = object.request.comments_url
          end
        end

        def handle?
          object.pull_request?
        end

        def handle
          Task.run(:github, payload, :url => url)
        end

        Notification::Instrument::Event::Handler::Github.attach_to(self)
      end
    end
  end
end
