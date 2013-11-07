module Travis
  module Api
    module V0
      module Worker
        class Job
          require 'travis/api/v0/worker/job/test'

          attr_reader :job

          def initialize(job, options = {})
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

          def build
            request
          end

          def admin
            repository.admin
          end
        end
      end
    end
  end
end
