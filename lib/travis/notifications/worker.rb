require 'active_support/core_ext/module/delegation'
require 'core_ext/module/async'

module Travis
  module Notifications
    class Worker
      autoload :Payload, 'travis/notifications/worker/payload'

      EVENTS = /job:.*:created/

      include Logging

      class << self
        def enqueue(job)
          new.enqueue(job)
        end

        def amqp
          @amqp ||= Travis::Amqp
        end

        def amqp=(amqp)
          @amqp = amqp
        end
      end

      delegate :amqp, :queue_for, :payload_for, :to => :'self.class'

      def notify(event, object, *args)
        ActiveSupport::Notifications.instrument('notify', :target => self, :args => [event, object, *args]) do
          enqueue(object)
        end
      end

      def enqueue(job)
        amqp.publish(job.queue, Payload.for(job))
      end
    end
  end
end
