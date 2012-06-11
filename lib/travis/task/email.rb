require 'core_ext/module/include'
require 'net/smtp'

module Travis
  class Task

    # Sends out build notification emails using ActionMailer.
    class Email < Task
      private

        def process
          Travis::Mailer::Build.send(:"#{data['build']['state']}_email", data, options[:recipients]).deliver
        end
    end
  end
end
