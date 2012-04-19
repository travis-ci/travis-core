module Travis
  module Notifications
    module Json
      module Worker
        class Job
          autoload :Configure, 'travis/notifications/json/worker/job/configure'
          autoload :Test,      'travis/notifications/json/worker/job/test'

          attr_reader :job

          def initialize(job)
            @job = job
          end

          def commit
            job.commit
          end

          def repository
            job.repository
          end

          def request
            job.source
          end
        end
      end
    end
  end
end
