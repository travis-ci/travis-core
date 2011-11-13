require 'amqp'
require 'amqp/utilities/event_loop_helper'
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
        def connect(config)
          AMQP::Utilities::EventLoopHelper.run
          AMQP.start(config)
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
