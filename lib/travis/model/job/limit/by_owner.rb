class Job
  module Limit
    class ByOwner
      attr_reader :owner

      def initialize(owner)
        @owner = owner
      end

      def all
        if custom_queue?
          queueable.all
        else
          queueable[0, max_queueable]
        end
      end

      def queueable
        Job.owned_by(owner).queueable
      end

      def running
        Job.owned_by(owner).running
      end

      def limited?
        running.count >= max_jobs
      end

      def max_queueable
        queueable = max_jobs - running.count
        queueable < 0 ? 0 : queueable
      end

      def max_jobs
        Travis.config.jobs.queue.limit
      end

      def custom_queue?
        %w(rails spree).include?(owner.login) # TODO extract to ... where exactly?
      end
    end
  end
end
