module Travis
  module Services
    module Jobs

      # Finds owners that have queueable jobs and for each owner:
      #
      #   * checks how many jobs can be enqueued
      #   * finds the oldest N queueable jobs and
      #   * enqueues them
      class Enqueue
        autoload :Limit, 'travis/services/jobs/enqueue/limit'

        extend Travis::Instrumentation, Travis::Exceptions::Handling

        def self.run
          new.run
        end

        attr_reader :reports

        def initialize
          @reports = {}
        end

        def run
          enqueue_all && reports unless disabled?
        end
        instrument :run
        rescues :run, from: Exception

        def disabled?
          Travis::Features.feature_deactivated?(:job_queueing)
        end

        private

          def enqueue_all
            jobs.group_by(&:owner).each do |owner, jobs|
              limit = Limit.new(owner, jobs)
              enqueue(limit.queueable)
              reports[owner.login] = limit.report
            end
          end

          def enqueue(jobs)
            jobs.each do |job|
              publish(job)
              job.enqueue
            end
          end

          def publish(job)
            payload = Travis::Api.data(job, for: 'worker', type: 'Job::Test', version: 'v0')
            publisher(job.queue).publish(payload, properties: { type: payload['type'] })
          end

          def jobs
            Job.includes(:owner).queueable
          end

          def publisher(queue)
            Travis::Amqp::Publisher.builds(queue)
          end
      end
    end
  end
end
