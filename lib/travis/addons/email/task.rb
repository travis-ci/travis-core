require 'net/smtp'

module Travis
  module Addons
    module Email

      # Sends out build notification emails using ActionMailer.
      class Task < Travis::Task
        def recipients
          @recipients ||= params[:recipients].select { |email| valid?(email) }
        end

        def type
          :"#{build[:state]}_email"
        end

        private

          def process
            Travis::Mailer::Build.send(type, payload, recipients).deliver if recipients.any?
          end

          def valid?(email)
            # stolen from http://is.gd/Dzd6fp because of it's beauty and all
            return false if email =~ /\.local$/
            mail = Mail::Address.new(email)
            tree = mail.__send__(:tree)
            mail.domain && mail.address == email && (tree.domain.dot_atom_text.elements.size > 1)
          rescue Exception => e
            false
          end

          Instruments::Task.attach_to(self)
      end
    end
  end
end
