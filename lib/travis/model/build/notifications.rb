require 'active_support/core_ext/object/blank'

class Build

  # Helpers that are used in various Travis::Notification handlers
  # and should probably be cleaned up and moved there TODO
  module Notifications
    DEFAULTS = {
      :start   => { :email => false,   :webhooks => false,   :campfire => false,   :irc => false   },
      :success => { :email => :change, :webhooks => :always, :campfire => :always, :irc => :always },
      :failure => { :email => :always, :webhooks => :always, :campfire => :always, :irc => :always }
    }

    def send_email_notifications_on_finish?
      !pull_request? && emails_enabled? && email_recipients.present? && notify_on_finish_for?(:email)
    end

    def send_webhook_notifications_on_start?
      !pull_request? && webhooks.any? && notify_on_start_for?(:webhooks)
    end

    def send_webhook_notifications_on_finish?
      !pull_request? && webhooks.any? && notify_on_finish_for?(:webhooks)
    end

    def send_campfire_notifications_on_finish?
      !pull_request? && campfire_rooms.any? && notify_on_finish_for?(:campfire)
    end

    def send_irc_notifications_on_finish?
      !pull_request? && irc_channels.any? && notify_on_finish_for?(:irc)
    end

    def notify_on_start_for?(type)
      config = config_with_fallbacks(type, :on_start, DEFAULTS[:start][type])
      config == true || config == :always
    end

    def notify_on_finish_for?(type)
      previous_on_branch.blank? || notify_on_success_for?(type) || notify_on_failure_for?(type)
    end

    def notify_on_success_for?(type)
      !!if passed?
        config = config_with_fallbacks(type, :on_success, DEFAULTS[:success][type])
        config == :always || (config == :change && !previous_passed?)
      end
    end

    def notify_on_failure_for?(type)
      !!if failed?
        config = config_with_fallbacks(type, :on_failure, DEFAULTS[:failure][type])
        config == :always || (config == :change && previous_passed?)
      end
    end

    def email_recipients
      @email_recipients ||= if (recipients = notification_values(:email, :recipients)).any?
        recipients
      else
        notifications[:recipients] || default_email_recipients # TODO deprecate recipients
      end
    end

    def webhooks
      @webhooks ||= notification_values(:webhooks, :urls).map { |webhook| webhook.split(' ') }.flatten.map(&:strip).reject(&:blank?)
    end

    def campfire_rooms
      @campfire_rooms ||= notification_values(:campfire, :rooms).map { |room| room.split(' ') }.flatten.map(&:strip).reject(&:blank?)
    end

    def irc_channels
      @irc_channels ||= notification_values(:irc, :channels).inject(Hash.new([])) do |servers, url|
        # TODO parsing irc urls should probably happen in the client class
        server_and_port, channel = url.split('#', 2)
        server, port = server_and_port.split(':')
        servers[[server, port]] += [channel]
        servers
      end
    end

    protected

      # Fetches config with fallbacks. (notification type > global > default)
      # Filters can be configured for each notification type.
      # If no rules are configured for the given type, then fall back to the global rules, and then to the defaults.
      def config_with_fallbacks(type, key, default)
        config = if (notifications[type] && notifications[type].is_a?(Hash) && notifications[type].has_key?(key))
          # Returns the type config if key is present (:notifications => :email => [:on_success])
          notifications[type][key]
        elsif notifications.has_key?(key)
          # Returns the global config if key is present (:notifications => [:on_success])
          notifications[key]
        else
          # Else, returns the given default
          default
        end

        config.respond_to?(:to_sym) ? config.to_sym : config
      end

      # Returns (recipients, urls, channels) for (email, webhooks, irc)
      # Supported data types are Hash, Array and String
      def notification_values(type, hash_key)
        config = notifications[type]
        # Notification type config can be a string, an array of values,
        # or a hash containing a key for these values.
        Array(config.is_a?(Hash) ? config[hash_key] : config)
      end

      def emails_enabled?
        return !!notifications[:email] if notifications.has_key?(:email)
        [:disabled, :disable].each { |key| return !notifications[key] if notifications.has_key?(key) } # TODO deprecate disabled and disable
        true
      end

      def previous_passed?
        previous_on_branch.try(:passed?)
      end

      def default_email_recipients
        recipients = [commit.committer_email, commit.author_email, repository.owner_email]
        recipients.select(&:present?).join(',').split(',').map(&:strip).uniq.join(',')
      end

      def notifications
        Travis::Notifications::SecureConfig.decrypt((config || {}).fetch(:notifications, {}), repository.key)
      end
  end
end
