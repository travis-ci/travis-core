require 'core_ext/module/include'
require 'net/smtp'

module Travis
  class Task

    # Sends out build notification emails using ActionMailer.
    class Email < Task
      include do
        attr_reader :recipients, :data

        def initialize(recipients, data)
          @recipients = recipients
          @data = data
        end

        def run
          email(recipients, data).deliver
        # rescue StandardError => e
        #   log_exception(e)
        end

        private

          def email(recipients, data)
            Travis::Mailer::Build.send(:"#{data['build']['state']}_email", data, recipients)
          end
      end
    end
  end
end
