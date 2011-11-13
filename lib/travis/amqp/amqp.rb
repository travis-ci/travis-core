require 'amqp'
require 'multi_json'

module Travis
  module Amqp
    class Amqp
      DEFAULTS = {
        :persistent  => true,
        :durable     => true,
        :auto_delete => false
      }

      class << self
        def connect
          AMQP.start(Travis.config.amqp)
        end
      end

      attr_reader :connection, :name

      def initialize(connection, name)
        @connection = connection
        @name = name
        # TODO what does this do? is this actually correct?
        require 'amqp/utilities/event_loop_helper'
        AMQP::Utilities::EventLoopHelper.run
      end

      def subscribe(options, &block)
        queue.subscribe(options, &block)
      end

      def publish(queue, data, options = {})
        data = MultiJson.encode(data) if data.is_a?(Hash)
        options = DEFAULTS.merge(options.merge(:routing_key => queue))
        exchange.publish(data, options)
      end

      protected

        def queue
          @queue ||= channel.queue(name, :durable => true, :exclusive => false)
        end

        def exchange
          @exchange ||= AMQP::Channel.new(connection).default_exchange
        end

        def channel
          @channel ||=  AMQP::Channel.new(connection).prefetch(Travis.config.amqp.prefetch)
        end
    end
  end
end
