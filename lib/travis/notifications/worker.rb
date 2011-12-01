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
      end

      delegate :queue_for, :payload_for, :to => :'self.class'

      def notify(event, object, *args)
        ActiveSupport::Notifications.instrument('notify', :target => self, :args => [event, object, *args]) do
          enqueue(object)
        end
      end

      def enqueue(job)
        publisher_for(job).publish(Payload.for(job))
      end

      protected

        def publisher_for(job)
          job.is_a?(Job::Configure) ? Travis::Amqp::Publisher.configure : Travis::Amqp::Publisher.builds(job.queue)
        end
    end
  end
end
