require 'active_support/notifications'

module Travis
  module Notifications
    module Instrumentation
      include Travis::Logging

      class << self
        def log_notification(channel, started_at, finished_at, hash, args)
          target, args = args.values_at(:target, :args)
          event = args.shift
          args = args.map { |arg| arg.is_a?(ActiveRecord::Base) ? "#<#{arg.class.name} id: #{arg.id}>" : arg.inspect }
          message = "#{channel} (#{finished_at - started_at}): #{target.class.name.demodulize} => #{event}: #{args.join(', ')}"
          info(colorize(:green, message), :header => 'Notfications')
        end
      end

      %w(archive email irc pusher webhook).each do |name| # TODO where can we hook in best?
        ActiveSupport::Notifications.subscribe(name, &method(:log_notification))
      end

      def instrument(*args, &block)
        ActiveSupport::Notifications.instrument(subscriber, :target => self, :args => args, &block)
      end
    end
  end
end
