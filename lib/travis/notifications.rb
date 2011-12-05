require 'active_support/core_ext/string/inflections'

module Travis
  module Notifications
    autoload :Handler,         'travis/notifications/handler'
    autoload :Instrumentation, 'travis/notifications/instrumentation'
    autoload :Subscription,    'travis/notifications/subscription'

    class << self
      include Logging

      def subscriptions
        @subscriptions ||= Travis.config.notifications.map do |name|
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

