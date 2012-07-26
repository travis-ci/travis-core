class Job
  module Limited
    class ByOwner
      attr_reader :queue

      def initialize(queue)
        @queue = queue
      end

      def first
        Job.queuable(queue).first if !limited? || custom_queue?
      end

      def limited?
        running >= max_jobs
      end

      def custom_queue?
        queue =~ /rails|spree/ # TODO extract to ... where exactly?
      end

      def running
        Job.running.count
      end

      def max_jobs
        5
      end
    end
  end
end
