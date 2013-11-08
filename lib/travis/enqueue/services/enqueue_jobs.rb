module Travis
  module Enqueue
    module Services
      # Finds owners that have queueable jobs and for each owner:
      #
      #   * checks how many jobs can be enqueued
      #   * finds the oldest N queueable jobs and
      #   * enqueues them
      class EnqueueJobs < Travis::Services::Base
        extend Travis::Instrumentation, Travis::Exceptions::Handling

        require 'travis/enqueue/services/enqueue_jobs/limit'

        register :enqueue_jobs

        def self.run
          new.run
        end

        def reports
          @reports ||= {}
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
              next unless owner
              limit = Limit.new(owner, jobs)
              enqueue(limit.queueable)
              reports[owner.login] = limit.report
            end
          end

          def enqueue(jobs)
            _jobs = jobs


            Metriks.timer('enqueue.publish_and_enqueue_total').time do
              _jobs.each do |job|
                publish(job)

                Metriks.timer('enqueue.enqueue_job').time do
                  job.enqueue
                end
              end
            end
          end

          def publish(job)
            Metriks.timer('enqueue.publish_job').time do
              payload = Travis::Api.data(job, for: 'worker', type: 'Job::Test', version: 'v0')
              publisher(job.queue).publish(payload, properties: { type: payload['type'] })
            end
          end

          def jobs
            Metriks.timer('enqueue.fetch_jobs').time do
              Job.includes(:owner).queueable
            end
          end

          def publisher(queue)
            Travis::Amqp::Publisher.builds(queue)
          end

          class Instrument < Notification::Instrument
            def run_completed
              publish(msg: format(target.reports), reports: target.reports)
            end

            def format(reports)
              reports = Array(reports)
              if reports.any?
                reports = reports.map do |repo, report|
                  "  #{repo}: #{report.map { |key, value| "#{key}: #{value}" }.join(', ')}"
                end
                "enqueued:\n#{reports.join("\n")}"
              else
                'nothing to enqueue.'
              end
            end
          end
          Instrument.attach_to(self)
      end
    end
  end
end
