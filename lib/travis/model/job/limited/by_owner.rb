class Job
  module Limited
    class ByOwner
      attr_reader :queue

      def initialize(queue)
        @queue = queue
      end

      def first
        if custom_queue?
          jobs.first
        else
          jobs.detect { |job| !limited?(job.owner) }
        end
      end

      def jobs
        Job.queuable(queue)
      end

      def limited?(owner)
        running(owner) >= max_jobs
      end

      def running(owner)
        Job.running.owned_by(owner).count
      end

      def custom_queue?
        queue =~ /rails|spree/ # TODO extract to ... where exactly?
      end

      def max_jobs
        Travis.config.jobs.queue.limit
      end
    end
  end
end
