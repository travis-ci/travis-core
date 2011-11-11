require 'hot_bunnies'
require 'multi_json'

module Travis
  module Amqp
    class HotBunnies
      def subscribe(options, &block)
        queue.subscribe(options, &block)
      end

      def publish(queue, data, options = {})
        data = MultiJson.encode(data) if data.is_a?(Hash)
        options = options.merge(:routing_key => queue)
        exchange.publish(data, options)
      end

      def disconnect
        connection.close if @connection
      end

      protected

        def queue
          @queue ||= channel.queue(REPORTING_KEY, :durable => true, :exclusive => false)
        end

        def exchange
          @exchange ||= channel.default_exchange
        end

        def channel
          @channel ||= connection.create_channel.tap do |channel|
            channel.prefetch = 1
          end
        end

        def connection
          @connection ||= ::HotBunnies.connect(Travis.config.amqp)
        end
    end
  end
end
