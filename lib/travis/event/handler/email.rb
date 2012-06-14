module Travis
  module Event
    class Handler

      # Sends out build notification emails using ActionMailer.
      class Email < Handler
        API_VERSION = 'v2'

        EVENTS = 'build:finished'

        def handle?
          config.send_on_finish?
        end

        def handle
          Task.run(:email, payload, :recipients => recipients)
        end

        def payload
          @payload ||= Api.data(object, :for => 'event', :version => API_VERSION)
        end

        def recipients
          config.recipients
        end

        def config
          @config ||= Config::Email.new(object)
        end

        Notification::Instrument::Event::Handler::Email.attach_to(self)
      end
    end
  end
end
