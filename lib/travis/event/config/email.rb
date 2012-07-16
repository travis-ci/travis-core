module Travis
  module Event
    class Config
      class Email < Config
        def send_on_finish?
          !build.pull_request? && emails_enabled? && send_on_finish_for?(:email)
        end

        def recipients
          @recipients ||= begin
            recipients = notification_values(:email, :recipients)
            recipients = recipients.any? ? recipients : notifications[:recipients] # TODO deprecate recipients
            Array(recipients || [])
          end
        end

        private

          def emails_enabled?
            return !!notifications[:email] if notifications.has_key?(:email)
            [:disabled, :disable].each { |key| return !notifications[key] if notifications.has_key?(key) } # TODO deprecate disabled and disable
            true
          end
      end
    end
  end
end
