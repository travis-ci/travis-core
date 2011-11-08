require 'amqp'

module Travis
  module Amqp
    class << self
      def setup_connection
        require 'amqp/utilities/event_loop_helper'
        AMQP::Utilities::EventLoopHelper.run

        AMQP.start(Travis.config.amqp) do |connection|
          Rails.logger.info 'Connected to AMQP broker'
          AMQP.channel = AMQP::Channel.new(connection)
        end
      end

      def publish(queue, payload)
        body = MultiJson.encode(payload)

        metadata = {
          :routing_key => queue,
          :persistent  => true,
          :durable     => true,
          :auto_delete => false
        }

        exchange.publish(body, metadata)
      end

      protected

        def exchange
          @exchange ||= AMQP.channel.default_exchange
        end
    end
  end
end
