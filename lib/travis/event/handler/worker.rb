module Travis
  module Event
    class Handler

      # Enqueues a remote job payload so it can be picked up and processed by a
      # worker.
      class Worker < Handler
        API_VERSION = 'v0'

        EVENTS = /worker:ready/

        def handle?
          !!job
        end

        def handle
          job.enqueue
          publisher.publish(payload, :properties => { :type => payload['type'] })
        end

        def queue
          object.queue
        end

        def job
          # TODO rate limit by repository owner
          @job ||= Job.queued(queue).first
        end

        def publisher
          Travis::Amqp::Publisher.builds(queue)
        end

        def payload
          @payload ||= Api.data(job, :for => 'worker', :type => 'Job::Test', :version => API_VERSION)
        end

        Notification::Instrument::Event::Handler::Worker.attach_to(self)
      end
    end
  end
end
