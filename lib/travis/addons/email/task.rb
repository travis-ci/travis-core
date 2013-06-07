require 'mail'

module Travis
  module Addons
    module Email

      # Sends out build notification emails using ActionMailer.
      class Task < Travis::Task
        def recipients
          @recipients ||= params[:recipients].select { |email| valid?(email) }
        end

        def broadcasts
          broadcasts = params[:broadcasts]
        end

        def type
          :finished_email
        end

        private

          def process
            Mailer::Build.send(type, payload, recipients, broadcasts).deliver if recipients.any?
          rescue StandardError => e
            # TODO notify the repo
            error("Could not send email to: #{recipients}")
            log_exception(e)
            raise
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
