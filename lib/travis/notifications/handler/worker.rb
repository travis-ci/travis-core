require 'core_ext/module/include'
require 'active_support/core_ext/module/delegation'

module Travis
  module Notifications
    module Handler

      # Enqueues a remote job payload so it can be picked up and processed by a
      # Worker.
      class Worker
        autoload :Payload, 'travis/notifications/handler/worker/payload'

        EVENTS = /job:.*:created/

        include Logging

        class << self
          def enqueue(job)
            new.enqueue(job)
          end
        end

        include do
          delegate :queue_for, :payload_for, :to => :'self.class'

          def notify(event, object, *args)
            ActiveSupport::Notifications.instrument('notify', :target => self, :args => [event, object, *args]) do
              enqueue(object)
            end
          end

          def enqueue(job)
            publisher_for(job).publish(Payload.for(job), :properties => { :type => type })
          end

          protected

            def publisher_for(job)
              job.is_a?(Job::Configure) ? Travis::Amqp::Publisher.configure : Travis::Amqp::Publisher.builds(job.queue)
            end
        end
      end
    end
  end
end
