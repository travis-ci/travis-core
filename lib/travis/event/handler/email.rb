module Travis
  module Event
    class Handler

      # Sends out build notification emails using ActionMailer.
      class Email < Handler
        include do
          API_VERSION = 'v2'

          EVENTS = 'build:finished'

          private

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
              Api.data(object, :for => 'event', :version => API_VERSION)
            end
        end
      end
    end
  end
end
