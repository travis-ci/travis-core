module Travis
  module Event
    class Config
      class Email < Config
        def send_on_finish?
          !build.pull_request? && emails_enabled? && recipients.present? && send_on_finish_for?(:email)
        end

        def recipients
          @recipients ||= if (recipients = notification_values(:email, :recipients)).any?
            recipients
          else
            notifications[:recipients] || default_email_recipients # TODO deprecate recipients
          end
        end

        private

          def emails_enabled?
            return !!notifications[:email] if notifications.has_key?(:email)
            [:disabled, :disable].each { |key| return !notifications[key] if notifications.has_key?(key) } # TODO deprecate disabled and disable
            true
          end

          def default_email_recipients
            recipients = [build.commit.committer_email, build.commit.author_email, repository.owner_email]
            recipients.select(&:present?).join(',').split(',').map(&:strip).uniq.join(',')
          end
      end
    end
  end
end
