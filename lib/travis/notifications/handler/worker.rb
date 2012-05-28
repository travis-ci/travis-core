require 'core_ext/module/include'
require 'active_support/core_ext/module/delegation'

module Travis
  module Notifications
    module Handler

      # Enqueues a remote job payload so it can be picked up and processed by a
      # Worker.
      class Worker
        API_VERSION = 'v0'

        EVENTS = /job:.*:created/

        include Logging

        class << self
          def enqueue(job)
            new.enqueue(job)
          end
        end

        include do
          delegate :queue_for, :payload_for, :to => :'self.class'

          def notify(event, job, *args)
            ActiveSupport::Notifications.instrument('notify', :target => self, :args => [event, job, *args]) do
              enqueue(job)
            end
          end

          def enqueue(job)
            publisher_for(job).publish(payload_for(job), :properties => { :type => job.class.name.demodulize.underscore })
          end

          private

            def publisher_for(job)
              job.is_a?(Job::Configure) ? Travis::Amqp::Publisher.configure : Travis::Amqp::Publisher.builds(job.queue)
            end

            def payload_for(job)
              Api.data(job, :for => 'worker', :type => job.class.name, :version => API_VERSION)
            end
        end
      end
    end
  end
end
