require 'active_support/notifications'

module Travis
  module Notifications
    module Instrumentation
      class << self
        include Travis::Logging

        def log_notification(channel, started_at, finished_at, hash, args)
          target, args = args.values_at(:target, :args)
          event = args.shift
          args = args.map { |arg| arg.is_a?(ActiveRecord::Base) ? "#<#{arg.class.name} id: #{arg.id}>" : arg.inspect }
          message = "#{event} (#{finished_at - started_at}) #{args.join(', ')}"
          info(colorize(:green, message), :header => channel)
        end
      end

      def notify(event, *args)
        instrument(event, *args) do
          super
        end
      end

      %w(archive email irc pusher webhook).each do |name| # TODO where can we hook in best?
        ActiveSupport::Notifications.subscribe(name.to_s, &method(:log_notification))
      end

      def instrument(*args, &block)
        ActiveSupport::Notifications.instrument(name.to_s, :target => self, :args => args, &block)
      end
    end
  end
end
