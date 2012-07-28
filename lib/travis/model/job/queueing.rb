class Job
  class Queueing
    class << self
      def all
        run(Job.queueable)
      end

      def by_owner(owner)
        run(Limit.all(owner), :force => true)
      end

      def run(jobs, options = {})
        jobs.each { |job| new(job, options).run }
      end
    end

    API_VERSION = 'v0'

    attr_reader :job, :options

    def initialize(job, options = {})
      @job = job
      @options = options
    end

    def run
      enqueue if options[:force] || enqueueable?
    end

    private

      def enqueue
        job.enqueue
        publisher.publish(payload, :properties => { :type => payload['type'] })
      end

      def enqueueable?
        Limit.enqueueable?(job)
      end

      def publisher
        @publisher ||= Travis::Amqp::Publisher.builds(job.queue)
      end

      def payload
        @payload ||= Travis::Api.data(job, :for => 'worker', :type => 'Job::Test', :version => API_VERSION)
      end
  end
end
