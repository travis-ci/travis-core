require 'core_ext/module/include'
require 'net/smtp'

module Travis
  module Notifications
    module Handler
      class Email
        EVENTS = 'build:finished'

        include Logging

        include do
          def notify(event, object, *args)
            send_emails(object) if object.send_email_notifications?
          rescue Exception => e
            log_exception(e)
          end

          protected

            def send_emails(object)
              email(object).deliver
            rescue Errno::ECONNREFUSED, Net::SMTPError => e
              error ["Error sending email: ", e.message, e.backtrace].join("\n")
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
