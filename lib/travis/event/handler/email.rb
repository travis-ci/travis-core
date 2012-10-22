require 'mail'

module Travis
  module Event
    class Handler

      # Sends out build notification emails using ActionMailer.
      class Email < Handler
        API_VERSION = 'v2'

        EVENTS = 'build:finished'

        attr_reader :payload

        def initialize(*)
          super
          @payload = Api.data(object, :for => 'event', :version => API_VERSION) if handle?
        end

        def handle?
          config.send_on_finish? && recipients.present?
        end

        def handle
          Task.run(:email, payload, :recipients => recipients)
        end

        def payload
          @payload ||= Api.data(object, :for => 'event', :version => API_VERSION)
        end

        def recipients
          @recipients ||= begin
            recipients = config.recipients.any? ? config.recipients : default_recipients
            recipients = recipients.select(&:present?).join(',').split(',').map(&:strip).uniq
            recipients.select { |email| valid_email?(email) }
          end
        end

        private

          def config
            @config ||= Config::Email.new(object)
          end

          def default_recipients
            [object.commit.committer_email, object.commit.author_email, object.repository.owner_email]
          end

          # stolen from http://my.rails-royce.org/2010/07/21/email-validation-in-ruby-on-rails-without-regexp
          # because of it's beauty and all
          def valid_email?(email)
            return false if email =~ /\.local$/
            m = Mail::Address.new(email)
            r = m.domain && m.address == email
            t = m.__send__(:tree)
            r && (t.domain.dot_atom_text.elements.size > 1)
          rescue Exception => e
          end

          Notification::Instrument::Event::Handler::Email.attach_to(self)
      end
    end
  end
end
