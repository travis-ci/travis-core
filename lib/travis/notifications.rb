require 'active_support/notifications'
require 'active_support/core_ext/string/inflections'

module Travis
  module Notifications
    autoload :Email,    'travis/notifications/email'
    autoload :Irc,      'travis/notifications/irc'
    autoload :Payload,  'travis/notifications/payload'
    autoload :Pusher,   'travis/notifications/pusher'
    autoload :Webhook,  'travis/notifications/webhook'
    autoload :Campfire, 'travis/notifications/campfire'
    autoload :Worker,   'travis/notifications/worker'

    class << self
      include Logging

      def subscriptions
        @subscriptions ||= Array(Travis.config.notifications).inject({}) do |subscriptions, subscriber|
          subscriber = const_get(subscriber.to_s.camelize)
          subscriptions.merge(subscriber.new => subscriber::EVENTS)
        end
      end

      def dispatch(event, *args)
        subscriptions.each do |subscriber, subscription|
          if matches?(subscription, event)
            subscriber.notify(event, *args)
          end
        end
      end

      def log_notify(channel, started_at, finished_at, hash, args)
        target, args = args.values_at(:target, :args)
        event = args.shift
        args = args.map { |arg| arg.is_a?(ActiveRecord::Base) ? "#<#{arg.class.name} id: #{arg.id}>" : arg.inspect }
        message = "#{channel} (#{finished_at - started_at}): #{target.class.name.demodulize} => #{event}: #{args.join(', ')}"
        info(colorize(:green, message), :header => 'Notfications')
      end

      protected

        def matches?(subscription, event)
          Array(subscription).any? do |subscription|
            subscription.is_a?(Regexp) ? subscription.match(event) : subscription == event
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

ActiveSupport::Notifications.subscribe('notify', &Travis::Notifications.method(:log_notify))
