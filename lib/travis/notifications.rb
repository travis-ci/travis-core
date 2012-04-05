require 'active_support/core_ext/string/inflections'

module Travis

  # Notification handlers register to events that are issued from state change
  # events on the core domain models (such as Request, Build, Job::Configure,
  # Job::Test).
  #
  # Handler registrations are defined in Travis.config so they can be added or
  # removed easily for different environments.
  #
  # Note that Travis::Notifications#notify accepts an internal event name like
  # 'create' (coming from the simple_states implementation in the models) and
  # turns it into a namespaced client event name like 'job:test:created').
  # Notification handlers register for and deal with these client event names.
  module Notifications
    autoload :Handler,         'travis/notifications/handler'
    autoload :Instrumentation, 'travis/notifications/instrumentation'
    autoload :Subscription,    'travis/notifications/subscription'
    autoload :SecureConfig,    'travis/notifications/secure_config'

    class << self
      include Logging

      def subscriptions
        @subscriptions ||= Travis.config.notifications.handlers.map do |name|
          Subscription.new(name)
        end
      end

      def dispatch(event, *args)
        subscriptions.each do |subscription|
          subscription.notify(event, *args)
        end
      end
    end

    def notify(event, *args)
      Travis::Notifications.dispatch(client_event(event, self), self, *args)
    end

    protected

      def client_event(event, object)
        event = "#{event}ed".gsub(/eded$|eed$/, 'ed') unless event == :log
        namespace = object.class.name.underscore.gsub('/', ':').gsub('travis:model:', '')
        [namespace, event].join(':')
      end
  end
end

