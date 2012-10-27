module Travis
  module Services
    module Jobs
      class Enqueue
        class Limit
          attr_reader :owner, :jobs, :config

          def initialize(owner, jobs)
            @owner = owner
            @jobs  = jobs
            @config = Travis.config.queue.limit
          end

          def queueable
            @queueable ||= jobs[0, max_queueable]
          end

          def report
            { total: jobs.size, running: running, max: max_jobs, queueable: queueable.size }
          end

          private

            def running
              @running ||= Job.owned_by(owner).running.count
            end

            def max_queueable
              if unlimited?
                999
              else
                queueable = max_jobs - running
                queueable < 0 ? 0 : queueable
              end
            end

            def max_jobs
              config.by_owner[owner.login] || config.default
            end

            def unlimited?
              %w(rails spree).include?(owner.login) # TODO extract to ... where exactly?
            end
        end
      end
    end
  end
end
