require 'hot_bunnies'
require 'multi_json'

module Travis
  module Amqp
    class HotBunnies
      class << self
        def connect(config)
          ::HotBunnies.connect(config)
        end
      end

      attr_reader :connection, :name

      def initialize(connection, name)
        @connection = connection
        @name = name
      end

      def subscribe(options, &block)
        queue.subscribe(options, &block)
      end

      def publish(queue, data, options = {})
        data = MultiJson.encode(data) if data.is_a?(Hash)
        options = options.merge(:routing_key => queue)
        put '-' * 200
        p exchange, data, options
        put '-' * 200
        exchange.publish(data, options)
      end

      protected

        def queue
          @queue ||= channel.queue(name, :durable => true, :exclusive => false)
        end

        def exchange
          @exchange ||= channel.default_exchange
        end

        def channel
          @channel ||= connection.create_channel.tap do |channel|
            channel.prefetch = 1
          end
        end
    end
  end
end
