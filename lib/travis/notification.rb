require 'active_support/core_ext/hash/reverse_merge'

module Travis
  module Notification
    autoload :Instrument, 'travis/notification/instrument'
    autoload :Publisher,  'travis/notification/publisher'

    class << self
      attr_accessor :publishers

      def setup
        Travis::Instrumentation.setup
        publishers << Publisher::Log.new
        publishers << Publisher::Redis.new if Travis::Features.feature_active?(:notifications_publisher_redis)
      end

      def publish(event)
        publishers.each { |publisher| publisher.publish(event) }
      end
    end

    self.publishers ||= []
  end
end
