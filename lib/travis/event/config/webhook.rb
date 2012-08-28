require 'active_support/core_ext/object/blank'

module Travis
  module Event
    class Config
      class Webhook < Config
        def include_logs?
          with_fallbacks(:webhooks, :include_logs, true)
        end

        def send_on_start?
          !build.pull_request? && webhooks.present? && send_on_start_for?(:webhooks)
        end

        def send_on_finish?
          !build.pull_request? && webhooks.any? && send_on_finish_for?(:webhooks)
        end

        def webhooks
          @webhooks ||= notification_values(:webhooks, :urls).map { |webhook| webhook.split(' ') }.flatten.map(&:strip).reject(&:blank?)
        end
      end
    end
  end
end
