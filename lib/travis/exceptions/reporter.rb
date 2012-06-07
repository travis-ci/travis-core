require 'thread'
require 'hubble'
require 'active_support/core_ext/class/attribute'

module Travis
  module Exceptions
    # A simple exception reporting queue that has a run loop in a separate
    # thread. Queued exceptions will be pushed to Hubble and logged.
    class Reporter
      class << self
        def enqueue(error)
          queue.push(error)
        end
      end

      class_attribute :queue
      self.queue = Queue.new

      attr_accessor :thread

      def run
        @thread = Thread.new &method(:error_loop)
      end

      def error_loop
        loop &method(:pop)
      end

      def pop
        handle(queue.pop)
      rescue => e
      end

      def handle(error)
        Hubble.report(error, metadata_for(error))
        Travis.logger.error("Error: #{error.message}")
      rescue => e
        puts "Error while handling exception: #{e.message}"
        puts e.backtrace
      end

      def metadata_for(error)
        metadata = { 'env' => Travis.env }
        metadata['payload']  = error.payload if error.respond_to?(:payload)
        metadata['event']    = error.event if error.respond_to?(:event)
        metadata['codename'] = ENV['CODENAME'] if ENV.key?('CODENAME')
        metadata
      end
    end
  end
end
