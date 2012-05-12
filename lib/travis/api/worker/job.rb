module Travis
  module Api
    module Worker
      class Job
        autoload :Configure, 'travis/api/worker/job/configure'
        autoload :Test,      'travis/api/worker/job/test'

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
