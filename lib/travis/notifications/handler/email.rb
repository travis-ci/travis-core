module Travis
  module Notifications
    class Handler

      # Sends out build notification emails using ActionMailer.
      class Email < Handler
        API_VERSION = 'v2'

        EVENTS = 'build:finished'

        private

          def handle?
            object.send_email_notifications_on_finish?
          end

          def handle
            Task::Email.new(recipients, data).run
          end

          def recipients
            object.email_recipients
          end

          def data
            Api.data(object, :for => 'notifications', :version => API_VERSION)
          end
      end
    end
  end
end
