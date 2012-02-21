require 'core_ext/module/include'
require 'net/smtp'

module Travis
  module Notifications
    module Handler

      # Sends out build notification emails using ActionMailer.
      class Email
        EVENTS = 'build:finished'

        include Logging

        include do
          def notify(event, object, *args)
            send_emails(object) if object.send_email_notifications?
          rescue StandardError => e
            log_exception(e)
          end

          protected

            def send_emails(object)
              email(object).deliver
            end

            def email(object)
              mailer(object).send(:"#{object.state}_email", object, object.email_recipients)
            end

            def mailer(object)
              Travis::Mailer.const_get(object.class.name.gsub('Travis::Model::', ''))
            end
        end
      end
    end
  end
end
