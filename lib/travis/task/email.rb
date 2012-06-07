require 'core_ext/module/include'
require 'net/smtp'

module Travis
  class Task

    # Sends out build notification emails using ActionMailer.
    class Email < Task
      attr_reader :recipients, :data

      def initialize(recipients, data)
        @recipients = recipients
        @data = data
      end

      private

        def process
          Travis::Mailer::Build.send(:"#{data['build']['state']}_email", data, recipients).deliver
        end
    end
  end
end
