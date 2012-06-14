module Travis
  module Event
    class Config
      autoload :Campfire, 'travis/event/config/campfire'
      autoload :Email,    'travis/event/config/email'
      autoload :Irc,      'travis/event/config/irc'
      autoload :Webhook,  'travis/event/config/webhook'

      DEFAULTS = {
        :start   => { :email => false,   :webhooks => false,   :campfire => false,   :irc => false   },
        :success => { :email => :change, :webhooks => :always, :campfire => :always, :irc => :always },
        :failure => { :email => :always, :webhooks => :always, :campfire => :always, :irc => :always }
      }

      attr_reader :repository, :build, :config

      def initialize(build)
        @build = build
        @config = build.config
        @repository = build.repository
      end

      private

        def send_on_start_for?(type)
          config = with_fallbacks(type, :on_start, DEFAULTS[:start][type])
          config == true || config == :always
        end

        def send_on_finish_for?(type)
          send_on_initial_build? || send_on_success_for?(type) || send_on_failure_for?(type)
        end

        def send_on_initial_build?
          build.previous_result.nil?
        end

        def send_on_success_for?(type)
          !!if build.passed?
            config = with_fallbacks(type, :on_success, DEFAULTS[:success][type])
            config == :always || (config == :change && !build.previous_passed?)
          end
        end

        def send_on_failure_for?(type)
          !!if build.failed?
            config = with_fallbacks(type, :on_failure, DEFAULTS[:failure][type])
            config == :always || (config == :change && build.previous_passed?)
          end
        end

        # Fetches config with fallbacks. (notification type > global > default)
        # Filters can be configured for each notification type.
        # If no rules are configured for the given type, then fall back to the global rules, and then to the defaults.
        def with_fallbacks(type, key, default)
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
        def notification_values(type, key)
          config = notifications[type]
          # Notification type config can be a string, an array of values,
          # or a hash containing a key for these values.
          Array(config.is_a?(Hash) ? config[key] : config)
        end

        def notifications
          Travis::Event::SecureConfig.decrypt(config.fetch(:notifications, {}), repository.key)
        end
    end
  end
end
