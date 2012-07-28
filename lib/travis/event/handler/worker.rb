module Travis
  module Event
    class Handler

      # Enqueues a remote job payload so it can be picked up and processed by a
      # worker.
      class Worker < Handler
        # Deactivated because
        #
        # a. the whole thing needs to be thread-safe on e.g. Job::Queueing#run
        #    i.e. when multiple events come in on separate threads in parallel
        #    then they've gotta wait.
        #
        # b. when Job.after_commit :on => :create is called then this handler
        #    will call Job::Test#enqueue and thus Job#update_attributes which
        #    in turn triggers the after_commit hook again, resulting in ~20
        #    published AMQP messages instead of just one.

        EVENTS = /--deactivated--/
        # EVENTS = /job:test:(created|finished)/

        def handle?
          false
        end

        def handle
          case event
          when 'job:test:created'
            Job::Queueing.new(object).run
          when 'job:test:finished'
            Job::Queueing.by_owner(object.owner)
          end
        end

        Notification::Instrument::Event::Handler::Worker.attach_to(self)
      end
    end
  end
end
