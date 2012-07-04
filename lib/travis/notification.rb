require 'active_support/core_ext/hash/reverse_merge'

module Travis
  module Notification
    autoload :Instrument, 'travis/notification/instrument'
    autoload :Publisher,  'travis/notification/publisher'

    class << self
      attr_accessor :publishers

      def setup
        Travis::Instrumentation.setup
        publishers << Publisher::Log.new << Publisher::Redis.new
      end

      def publish(event)
        publishers.each { |publisher| publisher.publish(event) }
      end
    end

    self.publishers ||= []
  end
end
