module Travis
  module Async
    class Queue
      attr_reader :name
      attr_reader :items

      @@lock = Mutex.new

      def initialize(name)
        @name  = name
        @items = []
        Thread.new { loop { work } }
      end

      def work
        block = with_lock { @items.pop }
        block.call if block
      end

      def <<(item)
        with_lock { @items << item }
      end

      private

      def with_lock
        @@lock.synchronize { yield }
      end
    end
  end
end
