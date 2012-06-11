module Travis
  module Event
    class Handler
      class Archive < Handler
        API_VERSION = 'v1'

        EVENTS = 'build:finished'

        def handle?
          true
        end

        def handle
          Task.run(:archive, payload)
        end

        def payload
          @payload ||= Api.data(object, :for => 'archive', :version => API_VERSION)
        end

        Notification::Instrument::Event::Handler::Archive.attach_to(self)
      end
    end
  end
end
