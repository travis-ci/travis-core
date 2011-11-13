module Travis
  module Amqp
    autoload :HotBunnies, 'travis/amqp/hot_bunnies'
    autoload :Amqp,       'travis/amqp/amqp'

    REPORTING_KEY = 'reporting.jobs'

    class << self
      def connected?
        !!@connection
      end

      def connection
        @connection ||= HotBunnies.connect(Travis::Worker.config.amqp)
      end
      alias :connect :connection

      def disconnect
        if connection
          connection.close
          @connection = nil
          @adapter = nil
        end
      end

      def subscribe(options, &block)
        adapter.subscribe(options, &block)
      end

      def publish(queue, payload, options = {}, &block)
        adapter.publish(queue, payload, options, &block)
      end

      protected

        def adapter
          @adapter ||= implementation.new(connection, REPORTING_KEY)
        end

        def implementation
          RUBY_PLATFORM == 'java' ? HotBunnies : Amqp
        end
    end
  end
end
