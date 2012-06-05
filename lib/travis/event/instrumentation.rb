require 'active_support/notifications'
require 'active_support/core_ext/string'
require 'metriks'

module Travis
  module Event

    # Subscribes to the ActiveSupport::Notification API so we can use it for
    # logging and instruments calls to `notify` (i.e. logs events).
    module Instrumentation
      class << self
        include Travis::Logging

        def log_notification(channel, started_at, finished_at, hash, args)
          time = finished_at - started_at
          Metriks.timer(channel).update(time)
        end
      end

      def notify(*args)
        instrument(*args) do
          super
        end
      end

      %w(archive email github irc pusher webhook).each do |name| # TODO where can we hook in best?
        ActiveSupport::Notifications.subscribe("#{name.to_s}.notifications.travis", &method(:log_notification))
      end

      def instrument(*args, &block)
        instrument_name = self.class.name.demodulize.downcase
        ActiveSupport::Notifications.instrument("#{instrument_name}.notifications.travis", :target => self, :args => [event, object, data] + args, &block)
      end
    end
  end
end
