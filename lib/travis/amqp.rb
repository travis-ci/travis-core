module Travis
  module Amqp
    autoload :HotBunnies, 'travis/amqp/hot_bunnies'
    autoload :Amqp,       'travis/amqp/amqp'

    REPORTING_KEY = 'reporting.jobs'

    class << self
      def subscribe(options, &block)
        adapter.subscribe(options, &block)
      end

      def publish(queue, payload, options = {}, &block)
        adapter.publish(queue, payload, options, &block)
      end
      end

      protected

        def adapter
          @adapter ||= RUBY_PLATFORM == 'java' ? HotBunnies.new : Amqp.new
        end
    end
  end
end
