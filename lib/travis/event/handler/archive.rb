module Travis
  module Event
    class Handler
      class Archive < Handler
        API_VERSION = 'v1'

        EVENTS = 'build:finished'

        attr_reader :payload

        def initialize(*)
          super
          @payload = Api.data(object, :for => 'archive', :version => API_VERSION) if handle?
        end

        def handle?
          true
        end

        def handle
          Task.run(:archive, payload)
        end

        Notification::Instrument::Event::Handler::Archive.attach_to(self)
      end
    end
  end
end
