require 'thread'
require 'core_ext/module/prepend_to'

module Travis
  module Async
    autoload :Queue, 'travis/async/queue'

    class << self
      attr_writer :enabled

      def enabled?
        !!@enabled
      end

      def run(name = nil, &block)
        queue = self.queue(name)
        queue << block
        info "Async queue size: #{queue.size}" if respond_to?(:info)
      end

      def queue(name)
        queues[name || :default] ||= Queue.new(name)
      end

      def queues
        @queues ||= {}
      end
    end

    def async(name, options = {})
      if Async.enabled?
        prepend_to name do |object, method, *args, &block|
          Async.run(options[:queue]) { method.call(*args, &block) }
        end
      end
    end
  end
end
