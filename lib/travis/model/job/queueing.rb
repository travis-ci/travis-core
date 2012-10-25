class Job
  class Queueing
    class All
      extend Travis::Instrumentation, Travis::Exceptions::Handling

      def run
        Job.queueable.map { |job| Queueing.new(job).run } unless disabled?
      end
      instrument :run
      rescues :run, :from => Exception unless Travis.env == 'test' # move to travis-support?

      def disabled?
        Travis::Features.feature_deactivated?(:job_queueing)
      end
    end

    # class << self
    #   def by_owner(owner)
    #     run(Limit.all(owner), :force => true)
    #   end
    # end

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
        job
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
