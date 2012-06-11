require 'core_ext/module/include'
require 'net/smtp'

module Travis
  class Task

    # Sends out build notification emails using ActionMailer.
    class Email < Task
      def recipients
        options[:recipients]
      end

      def type
        :"#{data['build']['state']}_email"
      end

      private

        def process
          Travis::Mailer::Build.send(type, data, recipients).deliver
        end

        Notification::Instrument::Task::Email.attach_to(self)
    end
  end
end
