module Travis
  module Event
    class Handler

      # Enqueues a remote job payload so it can be picked up and processed by a
      # Worker.
      class Worker < Handler
        API_VERSION = 'v0'

        EVENTS = /job:.*:created/

        class << self
          def enqueue(job)
            new('enqueued', job).notify
          end
        end

        def handle?
          true
        end

        def handle
          publisher.publish(payload, :properties => { :type => payload['type'] })
        end

        def publisher
          Travis::Amqp::Publisher.builds(object.queue)
        end

        def payload
          @payload ||= Api.data(object, :for => 'worker', :type => object.class.name, :version => API_VERSION)
        end

        Notification::Instrument::Event::Handler::Worker.attach_to(self)
      end
    end
  end
end
