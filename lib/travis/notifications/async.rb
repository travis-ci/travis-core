require 'girl_friday'

module Travis
  module Notifications
    module Async
      class Queue < GirlFriday::WorkQueue
        include Instrumentation

        attr_reader :callback

        def initialize(name, options = {}, &block)
          @callback = block
          options[:size] = Travis.config.async[name].try(:size) || 1
          super(name, options, &method(:handle))
        end

        def handle(event, *args)
          instrument(event, *args, &callback)
        end
      end

      def queues
        @queues ||= Travis.config.notifications.inject({}) do |queues, name|
          queues.merge(name => Queue.new(name))
        end
      end

      def notify(event, *args)
        queues[name].push([subscriber, event, *args]) if matches?(event)
      end
    end
  end
end

