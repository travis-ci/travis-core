require 'active_support/core_ext/hash/reverse_merge'

module Travis
  module Notification
    autoload :Instrument, 'travis/notification/instrument'
    autoload :Publisher,  'travis/notification/publisher'

    class << self
      def setup
        Travis::Instrumentation.setup
        publishers << Publisher::Log.new
      end

      def publishers
        @@publishers ||= []
      end

      def publish(event)
        publishers.each { |publisher| publisher.publish(event) }
      end
    end
  end
end
