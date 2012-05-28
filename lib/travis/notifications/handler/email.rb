require 'core_ext/module/include'
require 'net/smtp'

module Travis
  module Notifications
    module Handler

      # Sends out build notification emails using ActionMailer.
      class Email
        API_VERSION = 'v2'

        EVENTS = 'build:finished'

        include Logging

        include do
          attr_reader :build

          def notify(event, build, *args)
            @build = build # TODO move to initializer
            send(recipients, payload) if send?
          end

          private

            def send?
              build.send_email_notifications_on_finish?
            end

            def recipients
              build.email_recipients
            end

            def payload
              Api.data(build, :for => 'notifications', :version => API_VERSION)
            end

            # TODO --- extract ---

            def send(recipients, data)
              email(recipients, data).deliver
            # rescue StandardError => e
            #   log_exception(e)
            end

            def email(recipients, data)
              Travis::Mailer::Build.send(:"#{data['build']['state']}_email", data, recipients)
            end
        end
      end
    end
  end
end
