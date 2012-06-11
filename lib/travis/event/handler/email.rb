module Travis
  module Event
    class Handler

      # Sends out build notification emails using ActionMailer.
      class Email < Handler
        API_VERSION = 'v2'

        EVENTS = 'build:finished'

        def handle?
          object.send_email_notifications_on_finish?
        end

        def handle
          Task.run(:email, recipients, payload)
        end

        def recipients
          object.email_recipients
        end

        def payload
          @payload ||= Api.data(object, :for => 'event', :version => API_VERSION)
        end

        Instrument::Event::Handler::Email.attach_to(self)
      end
    end
  end
end
